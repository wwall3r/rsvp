-- verifies an email token by token and context
select
    u.*
from 
    users_tokens ut
inner join 
    users u 
on 
    ut.user_id = u.id
where
    ut.token = $1
    and ut.context = $2
    and ut.created_at > now() - interval '7 days'
