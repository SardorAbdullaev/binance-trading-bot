If you see

Error launching source instance: InvalidGroup.NotFound: The security group 'privatesecuritygroup' does not exist in VPC 'vpc-xxxx'

Use:
```hcl
  security_groups         = [aws_security_group.securitygroup.id]
```
instead of 
```hcl
  security_groups         = [aws_security_group.securitygroup.name]
```
