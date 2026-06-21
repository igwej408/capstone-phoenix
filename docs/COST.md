cat > COST.md << 'EOF'
# Infrastructure Cost

## Monthly Cost Breakdown (eu-north-1)

| Resource | Type | Qty | Unit Price | Monthly Cost |
|----------|------|-----|------------|-------------|
| EC2 control-plane | t3.small | 1 | ~$0.0208/hr | ~$15.00 |
| EC2 worker-1 | t3.micro | 1 | ~$0.0104/hr | ~$7.50 |
| EC2 worker-2 | t3.micro | 1 | ~$0.0104/hr | ~$7.50 |
| EBS volumes (20GB gp3 x3) | gp3 | 3 | ~$0.088/GB | ~$5.28 |
| S3 (terraform state) | Standard | 1 | negligible | ~$0.01 |
| DynamoDB (tf lock) | On-demand | 1 | negligible | ~$0.01 |
| Data transfer | Outbound | ~10GB | ~$0.09/GB | ~$0.90 |
| **Total** | | | | **~$36.20/month** |

## How to Cut It in Half

1. **Use Spot Instances for workers** — worker-1 and worker-2 can run as Spot instances at ~70% discount, saving ~$10/month since workloads reschedule automatically if interrupted.
2. **Downscale outside business hours** — use AWS Instance Scheduler to stop worker nodes nights and weekends, cutting compute costs by ~60%.
3. **Use a managed DB** — replace self-managed Postgres with RDS Free Tier (750hrs/month free for t3.micro) to eliminate the storage and compute overhead of running Postgres on a worker node.
4. **Move to a cheaper region** — eu-north-1 is slightly more expensive than us-east-1; switching saves ~10%.
EOF