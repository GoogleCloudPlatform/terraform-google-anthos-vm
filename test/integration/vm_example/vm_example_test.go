/**
 * Copyright 2022 Google LLC
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

package vmexample

import (
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/terraform-google-modules/anthos-vm/test/integration/remote"
)

func TestVMExample(t *testing.T) {
	example := tft.NewTFBlueprintTest(t)
	abmTest := remote.NewABMTest(t, example)
	example.DefineInit(abmTest.Init)
	example.DefineApply(abmTest.Apply)
	example.DefineVerify(abmTest.Verify)
	example.DefineTeardown(abmTest.Teardown)
	example.Test()
}
