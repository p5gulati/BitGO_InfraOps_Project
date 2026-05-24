# BitGo SWE InfraOps — Scalable Web Service

## Architecture
[handwritten diagram image]

Route 53 resolves paarth-infra.shop to an Application Load Balancer terminating TLS via ACM. The ALB distributes traffic across ECS Fargate tasks in two public subnets across us-east-1a and us-east-1b. IAM roles follow least-privilege as the execution role covers ECR pull and CloudWatch log delivery only; the task role is intentionally empty. Container image is stored in ECR and pulled by the execution role at task startup. CloudWatch Container Insights provides task-level metrics, log delivery via awslogs driver, and a dashboard covering request count, 5xx errors, response time, and running task count. Terraform state is stored remotely in S3 with native file locking. 

## Scaling
ECS Application Auto Scaling uses target tracking on ALBRequestCountPerTarget with a target of 100 requests per task per minute. Minimum 2 tasks (one per AZ for fault tolerance), maximum 4. Scale-out cooldown 30 seconds, scale-in stabilization 15 minutes. Verified under 1000 concurrent users generating 480 req/s, zero failures across 121,000 requests.

## What's Next
1. Move ECS tasks to private subnets with a NAT gateway. Currently tasks are in public subnets with security groups restricting inbound to ALB only, but private subnets would add defense in depth
2. Add VPC endpoints for ECR and CloudWatch which keeps traffic off the public internet and reduces NAT costs at scale
3. Wire FIS experiment template to a CI step, currently defined in Terraform but blocked by account subscription; would automate chaos testing on every deploy
4. Parameterise Terraform variables for region, cluster size, and scaling thresholds. Currently hardcoded, making multi-environment deployment require manual edits
5. Cost anomaly detection via AWS Cost Anomaly Monitor. BitGo operates at $1M+/month AWS spend; automated cost alerting is table stakes

## Trade-offs
Skipped private subnets and NAT gateway (~$32/month) in favour of public subnets with restrictive security groups. In production this would be non-negotiable. Tasks should never be directly addressable. For this project the security group locking inbound to the ALB security group only provides equivalent protection at zero cost, making it the right call for a time-bounded submission like this.
Moreover, FIS chaos experiment template is defined in fis.tf but could not be applied due to account subscription limitations, the experiment targets one ECS task via aws:ecs:stop-task with the 5xx alarm as a stop condition.