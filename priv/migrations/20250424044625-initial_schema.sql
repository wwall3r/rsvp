--- migration:up
create function set_updated_at() returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;


create table users(
  id uuid primary key default gen_random_uuid(),
  email varchar(255) not null,
  name varchar(255) not null,
  created_at timestamp not null default now(),
  updated_at timestamp not null default now(),
  deleted_at timestamp,
  unique (email)
);

create trigger users_updated_at before update on users for each row execute procedure set_updated_at();

create index users_email_index on users(email);

create table events(
  id uuid primary key default gen_random_uuid(),
  slug varchar(255) not null,
  name varchar(255) not null,
  description text not null,
  hosted_by varchar(255) not null,
  start_date timestamp not null,
  end_date timestamp,
  location varchar(255) not null,
  created_at timestamp not null default now(),
  updated_at timestamp not null default now(),
  deleted_at timestamp
);

create trigger events_updated_at before update on events for each row execute procedure set_updated_at();

create index events_slug_index on events(slug);

create table hosts(
  event_id uuid references events(id) on delete cascade,
  user_id uuid references users(id) on delete cascade,
  created_at timestamp not null default now(),
  updated_at timestamp not null default now(),
  deleted_at timestamp,
  primary key (event_id, user_id)
);

create trigger hosts_updated_at before update on hosts for each row execute procedure set_updated_at();

create index hosts_event_id_index on hosts(event_id);

create table host_invites(
  id uuid primary key default gen_random_uuid(),
  event_id uuid references events(id) on delete cascade,
  user_id uuid references users(id) on delete cascade,
  invite_code varchar(255) not null,
  note varchar(255),
  created_at timestamp not null default now(),
  updated_at timestamp not null default now(),
  deleted_at timestamp,
  unique (event_id, invite_code)
);

create trigger host_invites_updated_at before update on host_invites for each row execute procedure set_updated_at();

create index host_invites_event_id_index on host_invites(event_id);
create index host_invites_invite_code_index on host_invites(invite_code);

create table responses(
  id uuid primary key default gen_random_uuid(),
  event_id uuid references events(id) on delete cascade,
  user_id uuid references users(id) on delete cascade,
  guests integer not null constraint positive_guests check (guests > 0),
  message text,
  created_at timestamp not null default now(),
  updated_at timestamp not null default now(),
  deleted_at timestamp,
  unique (event_id, user_id)
);

create trigger responses_updated_at before update on responses for each row execute procedure set_updated_at();

create index responses_event_id_index on responses(event_id);
create index responses_user_id_index on responses(user_id);

--- migration:down
drop index responses_user_id_index;
drop index responses_event_id_index;
drop trigger responses_created_at on responses;
drop trigger responses_updated_at on responses;
drop table responses;

drop index host_invites_invite_code_index;
drop index host_invites_event_id_index;
drop trigger host_invites_created_at on host_invites;
drop trigger host_invites_updated_at on host_invites;
drop table host_invites;

drop index hosts_event_id_index;
drop trigger hosts_created_at on hosts;
drop trigger hosts_updated_at on hosts;
drop table hosts;

drop index events_slug_index;
drop trigger events_updated_at on events;
drop trigger events_created_at on events;
drop table events;

drop index users_email_index;
drop trigger users_created_at on users;
drop trigger users_updated_at on users;
drop table users;

drop function set_updated_at();

--- migration:end
