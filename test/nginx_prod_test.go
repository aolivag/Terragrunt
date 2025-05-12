package test

import (
	"crypto/tls"
	"fmt"
	"net/http"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestNginxDeploymentProd(t *testing.T) {
	// Skip this test by default since it requires real domain name and certificates
	// Only run this when explicitly testing production
	if testing.Short() {
		t.Skip("Skipping production test in short mode")
	}

	t.Parallel()

	// Path to the prod environment
	terragruntDir := "../terragrunt-nginx/environments/prod"

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

	// Configure HTTP client to trust invalid certificates (self-signed certs in test environment)
	httpClient := &http.Client{
		Timeout: 10 * time.Second,
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{
				InsecureSkipVerify: true,
			},
		},
	}

	maxRetries := 30
	sleepBetweenRetries := 5 * time.Second

	// Function to test the HTTP endpoint
	testEndpoint := func() error {
		resp, err := httpClient.Get(nginxUrl)
		if err != nil {
			return err
		}
		defer resp.Body.Close()

		if resp.StatusCode != 200 {
			return fmt.Errorf("expected status code 200, got %d", resp.StatusCode)
		}

		// Verify HTTPS is used in production
		if resp.TLS == nil {
			return fmt.Errorf("expected HTTPS connection but got HTTP")
		}

		return nil
	}

	// Retry until we get a successful response or time out
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

func TestPostgresDeploymentProd(t *testing.T) {
	// Skip this test by default
	if testing.Short() {
		t.Skip("Skipping production test in short mode")
	}

	t.Parallel()

	// Path to the prod-postgres environment
	terragruntDir := "../terragrunt-nginx/environments/prod-postgres"

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
}
