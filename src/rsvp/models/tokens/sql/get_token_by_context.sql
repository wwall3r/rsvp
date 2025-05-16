-- gets a token by token and context
select
    *
from
    users_tokens
where
    token = $1
    and context = $2
