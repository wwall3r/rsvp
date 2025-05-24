--- migration:up

create table users_tokens(
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete cascade,
  token bytea not null,
  context varchar(255) not null,
  sent_to varchar(255) not null,
  created_at timestamp not null default now(),
  unique (user_id, token)
);

create index users_tokens_user_id_index on users_tokens(user_id);

--- migration:down

drop index users_tokens_user_id_index;
drop trigger users_tokens_created_at on users_tokens;
drop table users_tokens;

--- migration:end
