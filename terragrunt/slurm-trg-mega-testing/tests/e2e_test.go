package test

import (
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerragruntExample(t *testing.T) {
	tgOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir:    "../test",
		TerraformBinary: "terragrunt",
	})
	defer terraform.TgDestroyAll(t, tgOptions)
	terraform.TgApplyAll(t, tgOptions)
	publicIp := terraform.Output(t, terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir:    "../test/load-balancer",
		TerraformBinary: "terragrunt",
	}), "public_ip")
	assert.NotEmpty(t, publicIp)
	http_helper.HttpGetWithRetry(t, "http://"+publicIp, nil, 200, "Hello from Yandex", 60, 10*time.Second)
}
