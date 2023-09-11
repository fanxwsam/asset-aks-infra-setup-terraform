-- -- 0-uuid-ossp-create-extension
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public ;
 
-- -- 3-public.users-table
-- CREATE TABLE public.users
-- (
--     id uuid default uuid_generate_v4()
--         constraint users_pkey
--             primary key,
--     nickname text,
--     timezone text,
--     created_by uuid,
--     updated_by uuid,
--     created_date timestamp with time zone default current_timestamp,
--     updated_date timestamp with time zone default current_timestamp,
--     deleted_by uuid,
--     deleted_date timestamp with time zone
-- );

-- -- 3-public.user_detail-table
-- CREATE TABLE public.user_detail
-- (
--     id uuid default uuid_generate_v4()
--         constraint user_detail_pkey
--             primary key,
--     country text,
--     city text,
--     gender text,
--     dob timestamp with time zone,
--     gender_assigned_at_birth text,
--     ethnicity text,
--     user_id uuid,
--     created_by uuid,
--     updated_by uuid,
--     created_date timestamp with time zone default current_timestamp,
--     updated_date timestamp with time zone default current_timestamp,
--     deleted_by uuid,
--     deleted_date timestamp with time zone
-- );

-- CREATE INDEX user_detail_users_user_id_idx
--     on public.user_detail (user_id);

 

-- -- 3-public.user_contact-table
-- CREATE TABLE public.user_contact
-- (
--     id uuid default uuid_generate_v4()
--         constraint user_contact_pkey
--             primary key,
--     name text,
--     first_name text,
--     last_name text,
--     email text not null,
--     phone text,
--     email_confirmed boolean default false,
--     user_id uuid,
--     created_by uuid,
--     updated_by uuid,
--     created_date timestamp with time zone default current_timestamp,
--     updated_date timestamp with time zone default current_timestamp,
--     deleted_by uuid,
--     deleted_date timestamp with time zone
-- );

-- CREATE INDEX user_contact_users_user_id_idx
--     on public.user_contact (user_id);

-- $BODY$;


CREATE TABLE public.users
(
    first_name text,
    last_name text,
    gender text,
    nickname text,
    timezone text
);
