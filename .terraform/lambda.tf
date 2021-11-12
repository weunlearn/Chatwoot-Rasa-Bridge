variable "publish" {
  default = false
}

variable "lambda_function_name" {
  default = "bridge-rasa"
}
resource "aws_kms_key" "rasa-lambda" {

}
resource "aws_lambda_function" "rasa_bridge" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.rasa-bridge.arn
  publish       = var.publish
  image_uri     = ""
  package_type  = "Image"
  environment {
    variables = {
      rasa_url           = "https://rasawulu.ddns.net"
      chatwoot_url       = "https://weunlearn.hopto.org"
      chatwoot_bot_token = "RhmauoS5Yd5n1iNjxEFTKURV"
      account_id         = "1"
    }
  }
  handler = "index.js"

}

resource "aws_cloudwatch_log_group" "rasa-bridge" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 30
}
resource "aws_iam_role" "rasa-bridge" {
  name               = "Iam_role_Rasa_bridge"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": "logs:CreateLogGroup",
        "Resource": "arn:aws:logs:ap-south-1:572260955088:*"
      },
      {
        "Sid": "VisualEditor1",
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:ap-south-1:572260955088:log-group:/aws/lambda/bridge-rasa:*"
      },
      {
        "Sid": "VisualEditor2",
        "Effect": "Allow",
        "Action": "translate:*",
        "Resource": "*"
      }
    ]
  }
  EOF
}

data "aws_iam_policy" "lambda_logging"{
  name = "lambda_logging"
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.rasa-bridge.name
  policy_arn = data.aws_iam_policy.lambda_logging.arn
}