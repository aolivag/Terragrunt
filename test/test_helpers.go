package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

// GetTerragruntOptions returns Terragrunt options for the specified directory
func GetTerragruntOptions(t *testing.T, terragruntDir string) *terraform.Options {
	return terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir:    terragruntDir,
		TerraformBinary: "terragrunt",
		EnvVars: map[string]string{
			"TF_CLI_ARGS": "-no-color",
		},
	})
}

// ApplyAndVerify is a helper function to apply Terragrunt code and verify outputs
func ApplyAndVerify(t *testing.T, terragruntDir string, outputsToVerify []string) map[string]string {
	// Get Terragrunt options
	terragruntOptions := GetTerragruntOptions(t, terragruntDir)

	// Clean up resources when the test is complete
	defer terraform.TgDestroyAll(t, terragruntOptions)

	// Run "terragrunt apply"
	terraform.TgApplyAll(t, terragruntOptions)

	// Get and verify all requested outputs
	outputs := make(map[string]string)

	for _, output := range outputsToVerify {
		outputValue := terraform.Output(t, terragruntOptions, output)
		if outputValue == "" {
			t.Fatalf("Output %s is empty", output)
		}
		outputs[output] = outputValue
	}

	return outputs
}
