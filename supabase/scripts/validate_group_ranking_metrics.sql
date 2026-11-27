-- Run this entire script in Supabase SQL Editor as postgres after applying the ranking migration.
-- The ranking RPC is invoked as authenticated with simulated JWT claims.
-- Test fixtures are rolled back by the exception block; no test rows are committed.
DO $$
DECLARE
    v_member_a UUID := gen_random_uuid();
    v_member_b UUID := gen_random_uuid();
    v_outsider UUID := gen_random_uuid();
    v_group UUID := gen_random_uuid();
    v_other_group UUID := gen_random_uuid();
    v_late_event UUID := gen_random_uuid();
    v_extra_late_event UUID := gen_random_uuid();
    v_middle_event UUID := gen_random_uuid();
    v_latest_event UUID := gen_random_uuid();
    v_active_event UUID := gen_random_uuid();
    v_other_group_event UUID := gen_random_uuid();
    v_first_id UUID;
    v_metrics RECORD;
    v_error TEXT;
BEGIN
    BEGIN
        INSERT INTO auth.users (
            id,
            aud,
            role,
            email,
            encrypted_password,
            email_confirmed_at,
            raw_app_meta_data,
            raw_user_meta_data,
            created_at,
            updated_at
        )
        VALUES
            (
                v_member_a,
                'authenticated',
                'authenticated',
                v_member_a::TEXT || '@ranking-test.invalid',
                '',
                NOW(),
                '{}'::JSONB,
                '{"nickname":"Ranking Test A"}'::JSONB,
                NOW(),
                NOW()
            ),
            (
                v_member_b,
                'authenticated',
                'authenticated',
                v_member_b::TEXT || '@ranking-test.invalid',
                '',
                NOW(),
                '{}'::JSONB,
                '{"nickname":"Ranking Test B"}'::JSONB,
                NOW(),
                NOW()
            ),
            (
                v_outsider,
                'authenticated',
                'authenticated',
                v_outsider::TEXT || '@ranking-test.invalid',
                '',
                NOW(),
                '{}'::JSONB,
                '{"nickname":"Ranking Test Outsider"}'::JSONB,
                NOW(),
                NOW()
            );

        INSERT INTO public.groups (id, invitation_code, group_name)
        VALUES
            (v_group, 'ranking-test-' || v_group::TEXT, 'Ranking test group'),
            (
                v_other_group,
                'ranking-test-' || v_other_group::TEXT,
                'Other ranking test group'
            );

        INSERT INTO public.groups_memberships (group_id, user_id, role)
        VALUES
            (v_group, v_member_a, 0),
            (v_group, v_member_b, 1),
            (v_other_group, v_member_a, 1);

        INSERT INTO public.events (
            id,
            group_id,
            title,
            destination_name,
            arrival_time,
            status
        )
        VALUES
            (
                v_late_event,
                v_group,
                'Old late event',
                'Test destination',
                NOW() - INTERVAL '20 minutes',
                'completed'
            ),
            (
                v_extra_late_event,
                v_group,
                'Additional late event',
                'Test destination',
                NOW() - INTERVAL '5 minutes',
                'completed'
            ),
            (
                v_middle_event,
                v_group,
                'On-time event',
                'Test destination',
                NOW() + INTERVAL '5 minutes',
                'completed'
            ),
            (
                v_latest_event,
                v_group,
                'Latest event',
                'Test destination',
                NOW() + INTERVAL '10 minutes',
                'completed'
            ),
            (
                v_active_event,
                v_group,
                'Uncompleted event',
                'Test destination',
                NOW() - INTERVAL '3 hours',
                'active'
            ),
            (
                v_other_group_event,
                v_other_group,
                'Other group event',
                'Test destination',
                NOW() - INTERVAL '90 minutes',
                'completed'
            );

        INSERT INTO public.event_reports (event_id, user_id, status)
        VALUES
            (v_late_event, v_member_a, 0),
            (v_middle_event, v_member_a, 0),
            (v_latest_event, v_member_a, 0),
            (v_late_event, v_member_b, 0),
            (v_extra_late_event, v_member_b, 0),
            (v_middle_event, v_member_b, 0),
            (v_latest_event, v_member_b, 0),
            (v_active_event, v_member_a, 0),
            (v_other_group_event, v_member_a, 0);

        PERFORM set_config('app.rpc_updating', 'true', TRUE);

        UPDATE public.event_reports AS report
        SET status = update_data.status
        FROM (
            VALUES
                (v_late_event, v_member_a, 5),
                (v_middle_event, v_member_a, 4),
                (v_latest_event, v_member_a, 4),
                (v_late_event, v_member_b, 5),
                (v_extra_late_event, v_member_b, 5),
                (v_middle_event, v_member_b, 4),
                (v_active_event, v_member_a, 5),
                (v_other_group_event, v_member_a, 5)
        ) AS update_data(event_id, user_id, status)
        WHERE report.event_id = update_data.event_id
          AND report.user_id = update_data.user_id;

        IF NOT has_function_privilege(
            'authenticated',
            'public.get_group_rankings(uuid)'::REGPROCEDURE,
            'EXECUTE'
        ) THEN
            RAISE EXCEPTION 'authenticated is missing EXECUTE on get_group_rankings';
        END IF;

        IF has_function_privilege(
            'anon',
            'public.get_group_rankings(uuid)'::REGPROCEDURE,
            'EXECUTE'
        ) THEN
            RAISE EXCEPTION 'anon unexpectedly has EXECUTE on get_group_rankings';
        END IF;

        PERFORM set_config('request.jwt.claim.sub', v_member_b::TEXT, TRUE);
        PERFORM set_config('request.jwt.claim.role', 'authenticated', TRUE);
        PERFORM set_config(
            'request.jwt.claims',
            json_build_object('sub', v_member_b, 'role', 'authenticated')::TEXT,
            TRUE
        );

        SET LOCAL ROLE authenticated;
        IF current_user <> 'authenticated' THEN
            RAISE EXCEPTION 'Could not switch to the authenticated database role';
        END IF;

        SELECT id
        INTO v_first_id
        FROM public.get_group_rankings(v_group)
        LIMIT 1;

        IF v_first_id IS DISTINCT FROM v_member_b THEN
            RAISE EXCEPTION 'Expected member B to rank first by total delay';
        END IF;

        SELECT streak, total_delay_minutes, avg_delay_minutes
        INTO v_metrics
        FROM public.get_group_rankings(v_group)
        WHERE id = v_member_a;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Member A was missing from the group ranking';
        END IF;

        IF v_metrics.streak <> 2
           OR v_metrics.total_delay_minutes <> 20
           OR v_metrics.avg_delay_minutes <> 7 THEN
            RAISE EXCEPTION 'Unexpected member A metrics: %', row_to_json(v_metrics);
        END IF;

        SELECT streak, total_delay_minutes, avg_delay_minutes
        INTO v_metrics
        FROM public.get_group_rankings(v_group)
        WHERE id = v_member_b;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Member B was missing from the group ranking';
        END IF;

        IF v_metrics.streak <> 0
           OR v_metrics.total_delay_minutes <> 25
           OR v_metrics.avg_delay_minutes <> 8 THEN
            RAISE EXCEPTION 'Unexpected member B metrics: %', row_to_json(v_metrics);
        END IF;

        PERFORM set_config('request.jwt.claim.sub', v_outsider::TEXT, TRUE);
        PERFORM set_config(
            'request.jwt.claims',
            json_build_object('sub', v_outsider, 'role', 'authenticated')::TEXT,
            TRUE
        );

        BEGIN
            PERFORM 1 FROM public.get_group_rankings(v_group);
            RAISE EXCEPTION 'Expected a non-member to be rejected';
        EXCEPTION
            WHEN OTHERS THEN
                GET STACKED DIAGNOSTICS v_error = MESSAGE_TEXT;
                IF v_error <> 'Not a group member' THEN
                    RAISE;
                END IF;
        END;

        RESET ROLE;

        RAISE EXCEPTION 'ranking_validation_rollback';
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS v_error = MESSAGE_TEXT;
            IF v_error <> 'ranking_validation_rollback' THEN
                RAISE;
            END IF;
    END;
END;
$$;

SELECT 'Group ranking validation passed' AS result;
