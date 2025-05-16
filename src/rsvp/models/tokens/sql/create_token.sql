-- creates a token
insert into
    users_tokens(user_id, token, context, sent_to)
values
    ($1, $2, $3, $4)
returning
    *
