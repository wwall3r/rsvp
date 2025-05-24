-- updates a user
update
    users
set
    name = $2,
    email = $3
where
    id = $1
returning
    *
