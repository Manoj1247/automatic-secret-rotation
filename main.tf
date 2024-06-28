module "secrets" {
  source = "./modules/secrets"

  lambda_arn = module.functions.lambda_arn
}

module "functions" {
  source = "./modules/functions"

  secret_id = module.secrets.secret_id
  secret_arn = module.secrets.secret_arn
}