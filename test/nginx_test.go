package test

import (
	"fmt"
	"net/http"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestNginxDeploymentDev(t *testing.T) {
	t.Parallel()

	// Path to the dev environment
	terragruntDir := "../terragrunt-nginx/environments/dev"

	// Configure Terragrunt options
	terragruntOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir:    terragruntDir,
		TerraformBinary: "terragrunt",
		EnvVars: map[string]string{
			"TF_CLI_ARGS": "-no-color",
		},
	})

	// Clean up resources when the test is complete
	defer terraform.TgDestroyAll(t, terragruntOptions)

	// Run "terragrunt apply"
	terraform.TgApplyAll(t, terragruntOptions)

	// Get the URL output from Terraform
	nginxUrl := terraform.Output(t, terragruntOptions, "nginx_url")
	assert.NotEmpty(t, nginxUrl)

	// Make HTTP request to the Nginx server
	maxRetries := 30
	sleepBetweenRetries := 5 * time.Second

	// Function to test the HTTP endpoint
	testEndpoint := func() error {
		resp, err := http.Get(nginxUrl)
		if err != nil {
			return err
		}
		defer resp.Body.Close()

		if resp.StatusCode != 200 {
			return fmt.Errorf("expected status code 200, got %d", resp.StatusCode)
		}

		return nil
	}

	// Retry until we get a 200 OK response or time out
	for i := 0; i < maxRetries; i++ {
		err := testEndpoint()
		if err == nil {
			break
		}

		if i == maxRetries-1 {
			t.Fatalf("Failed to get successful response after %d retries: %v", maxRetries, err)
		}

		t.Logf("Nginx server not ready yet (attempt %d/%d): %v. Waiting %v...", i+1, maxRetries, err, sleepBetweenRetries)
		time.Sleep(sleepBetweenRetries)
	}
}

func TestPostgresDeploymentDev(t *testing.T) {
	t.Parallel()

	// Path to the dev-postgres environment
	terragruntDir := "../terragrunt-nginx/environments/dev-postgres"

	// Configure Terragrunt options
	terragruntOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir:    terragruntDir,
		TerraformBinary: "terragrunt",
		EnvVars: map[string]string{
			"TF_CLI_ARGS": "-no-color",
		},
	})

	// Clean up resources when the test is complete
	defer terraform.TgDestroyAll(t, terragruntOptions)

	// Run "terragrunt apply"
	terraform.TgApplyAll(t, terragruntOptions)

	// Get outputs from Terraform
	postgresHost := terraform.Output(t, terragruntOptions, "postgres_host")
	postgresPort := terraform.Output(t, terragruntOptions, "postgres_port")

	assert.NotEmpty(t, postgresHost)
	assert.NotEmpty(t, postgresPort)

	// Additional connectivity tests could be implemented here
	// This would typically involve using a Postgres client to verify connectivity
	// For simplicity, we're just checking that outputs exist
}
