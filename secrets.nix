# Auto-generated from README.org
let
  users = {
    fleurs = "age1yubikey1qvqpv4f2kvwxzdf4rm349za00jayxhk23ads42l92sjywlcwce20yhm6pm2";
  };
in
{
  "secrets/env.age".publicKeys = [
    users.fleurs
  ];
}
