-- gets a token
select
    *
from
    users_tokens
where
    token = $1
