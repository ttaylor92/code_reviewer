# CodeReviewer

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/ttaylor92/code_reviewer/tree/master.svg?style=svg&circle-token=CCIPRJ_EW8pczxe9JWQVnikpLwyWC_7024332fff056faf3e1dfc74dcef39a85189fe3b)](https://dl.circleci.com/status-badge/redirect/gh/ttaylor92/code_reviewer/tree/master)
[![codecov](https://codecov.io/gh/ttaylor92/code_reviewer/graph/badge.svg?token=PTLD0JOI75)](https://codecov.io/gh/ttaylor92/code_reviewer)

## Application Architecture (completely free of cost)
1. Deployed to render for 24/7 uptime or a long running instance
2. GitHub Rest API's for annotations and webhooks for events
3. Circle CI Actions has been added for testing application code
	1. After successful testing deployment is triggered programmatically
	2. There is also integration with Codecov to track coverage of functions/edge cases
4. Cloudflare worker is triggered ever minute on a CRON job to ensure site is up 24/7 and available for PR event
5. Supabase DB to persist credentials
6. AI/ML API is use for the AI integration

## Request Process
![Diagram](https://i.imgur.com/kOHGstw.png)
1. Webhook is triggered due to an event (Pull Request)
2. Data received from starting event is used to query the diff information about the pull request
3. Information is parsed
4. Information is then submitted to the ML using the anti pattern guidelines (within `.ai-code-rules` directory) for context
5. Code review response is then aggregated and maps are generated to be used for annotation
6. Maps are sent to the rest API endpoint to update pr annotations/review comments

## Requirements
1. Currently one credential is stored at a time to use for the annotation submissions
	1. `github_api_token` - account to be used for the AI to add annotations to PRs
		1. [Managing your personal access tokens - GitHub Docs](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
	2. `ai_api_token` - token for use of the LLM
		1. [Setting Up | AI/ML API Documentation](https://docs.aimlapi.com/quickstart/setting-up#generating-an-aiml-api-key)

## Usage
1. GitHub project/s utilizing the AI review feature will need to be updated to use the webhook, event should be on PR not pushes
	1. Currently application is only tracking the opening, reopening & marking
	2. Endpoint is `<API_URL>/api/webhook
2. A request should be sent to `<API_URL>/api/credentials` with a JSON object containing the required credentials
	1. `github_api_token`: String
	2. `ai_api_token`: String
