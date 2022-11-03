/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package remote

import (
	"fmt"
	"path/filepath"
	"strings"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

var (
	remoteRoot = "/root"
)

type ABMTest struct {
	project         string
	zone            string
	ws              string
	localExampleDir string
	remoteDir       string
	envs            map[string]string
	t               *testing.T
}

func NewABMTest(t *testing.T, example *tft.TFBlueprintTest) *ABMTest {
	project := example.GetTFOptions().EnvVars["TF_VAR_project_id"]
	ws := example.GetTFOptions().EnvVars["TF_VAR_workstation"]
	zone := example.GetTFOptions().EnvVars["TF_VAR_zone"]
	exampleDir := example.GetTFOptions().TerraformDir
	return &ABMTest{
		project:         project,
		zone:            zone,
		ws:              ws,
		localExampleDir: exampleDir,
		envs:            example.GetTFOptions().EnvVars,
		t:               t,
	}
}

func (t *ABMTest) pathsToCopy() []string {
	examplesDir := filepath.Dir(t.localExampleDir)
	workspaceDir := filepath.Dir(examplesDir)
	moduelsDir := filepath.Join(workspaceDir, "modules")
	return []string{
		examplesDir,
		moduelsDir,
		filepath.Join(workspaceDir, "main.tf"),
		filepath.Join(workspaceDir, "variables.tf"),
		filepath.Join(workspaceDir, "versions.tf"),
		filepath.Join(workspaceDir, "outputs.tf"),
	}
}

func (t *ABMTest) Init(a *assert.Assertions) {
	for _, path := range t.pathsToCopy() {
		gcloud.RunCmd(t.t, fmt.Sprintf("compute scp --project=%s --zone=%s --recurse %s root@%s:%s", t.project, t.zone, path, t.ws, remoteRoot))
	}
	t.runCmdOnWorkstation(append(t.terraformCmd(), "init", "-input=false"))
}

func (t *ABMTest) Apply(a *assert.Assertions) {
	t.runCmdOnWorkstation(append(t.terraformCmd(), "apply", "-input=false", "-auto-approve"))
}

func (t *ABMTest) Verify(a *assert.Assertions) {
	t.runCmdOnWorkstation(append(t.terraformCmd(), "plan", "-input=false", "-detailed-exitcode"))
}

func (t *ABMTest) Teardown(a *assert.Assertions) {
	t.runCmdOnWorkstation(append(t.terraformCmd(), "destroy", "-input=false", "-auto-approve"))
	for _, path := range t.pathsToCopy() {
		t.runCmdOnWorkstation([]string{"rm", "-rf", filepath.Join(remoteRoot, filepath.Base(path))})
	}
}

func (t *ABMTest) terraformCmd() []string {
	var cmd []string
	for k, v := range t.envs {
		cmd = append(cmd, fmt.Sprintf("%s='%v'", k, v))
	}
	cmd = append(cmd, "terraform")
	cmd = append(cmd, fmt.Sprintf("-chdir=%s", filepath.Join(remoteRoot, "examples", filepath.Base(t.localExampleDir))))
	return cmd
}

func (t *ABMTest) runCmdOnWorkstation(cmd []string) string {
	cmdArg := fmt.Sprintf("--command=%s", strings.Join(cmd, " "))
	return gcloud.RunCmd(t.t, fmt.Sprintf("compute ssh --project=%s --zone=%s root@%s", t.project, t.zone, t.ws), gcloud.WithCommonArgs([]string{cmdArg}))
}
