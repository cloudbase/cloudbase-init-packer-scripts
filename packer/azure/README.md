# Azure Windows images with cloudbase-init

This directory contains the scripts and config files needed to generate Azure custom images with cloudbase-init.

## How to generate the images

### Requirements

* The `packer` tool installed. Download the latest binary for your platform from [here](https://www.packer.io/downloads).
* (Optional) The `az` CLI tool installed, if Azure images are published to a shared gallery.

### Image builder steps

1. Export the necessary environment variables for the image builder:

    ```bash
    export AZURE_SUBSCRIPTION_ID="<SUBSCRIPTION_ID>"
    export AZURE_TENANT_ID="<TENANT_ID>"
    export AZURE_CLIENT_ID="<CLIENT_ID>"
    export AZURE_CLIENT_SECRET="<CLIENT_SECRET>"

    export RESOURCE_GROUP_NAME="<TARGET_RESOURCE_GROUP_NAME>" # the resulting image will be created in this resource group
    ```

1. Run the packer image builder. Choose the variables file for the image you want to build. You may want to adjust the variables from the variables file to match your environment:

    ```bash
    packer build -var-file=ws2022-variables.json windows.json
    ```

    When the `packer build` finishes, the resulted Azure managed image is ready to be used.

1. (Optional) Publish the managed image into a shared gallery, in case you want it to be used into multiple regions:

    ```bash
    IMAGE_ID="/subscriptions/<subscription ID>/resourceGroups/myResourceGroup/providers/Microsoft.Compute/images/myImage"

    az sig image-version create \
        --resource-group cbsl-init-gallery-rg \
        --gallery-name cbsl_init_gallery \
        --gallery-image-definition ws-ltsc2022-cbsl-init \
        --gallery-image-version 2023.07.10 \
        --managed-image $IMAGE_ID \
        --target-regions westeurope eastus2 westus2 southcentralus \
        --replica-count 1
    ```
