module "secrets" {
  source = "./modules/secrets"

  lambda_arn = module.functions.lambda_arn
}

module "functions" {
  source = "./modules/functions"

  secret_id      = module.secrets.secret_id
  secret_arn     = module.secrets.secret_arn
  event_rule_arn = module.events.event_rule_arn
}

module "events" {
  source = "./modules/events"

  lambda_arn = module.functions.lambda_arn
}