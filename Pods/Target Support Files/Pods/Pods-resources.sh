#!/bin/sh
set -e

mkdir -p "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=""

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm\""
      xcrun mapc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      XCASSET_FILES="$XCASSET_FILES '${PODS_ROOT}/$1'"
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-Attachment.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-Attachment@2x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-Attachment@3x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-camera-button.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-camera-button@2x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-camera-button@3x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-delete-button.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-delete-button@2x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-delete-button@3x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-no-connection.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-no-connection@2x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-powered-by-logo.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-powered-by-logo@2x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-powered-by-logo@3x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-screenshot-error.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-screenshot-error@2x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSChatBubbleBlue.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSChatBubbleBlue@2x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSChatBubbleBlue@3x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSChatBubbleWhite.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSChatBubbleWhite@2x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSChatBubbleWhite@3x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSConfirmBox.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSConfirmBox@2x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSTutorial.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSTutorial@2x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSTutorial@3x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSTutorialiPad.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSTutorialiPad@2x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSTutorialiPad@3x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/ar.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/cs.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/de.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/en.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/es.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/fr.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/hu.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/id.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/it.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/ja.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/ko.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/nl.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/pl.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/pt.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/ru.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/sl.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/th.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/tr.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/vi.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/zh-Hans.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/zh-Hant.lproj"
  install_resource "${BUILT_PRODUCTS_DIR}/DMPasscode.bundle"
  install_resource "${BUILT_PRODUCTS_DIR}/LGSemiModalNavController.bundle"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-Attachment.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-Attachment@2x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-Attachment@3x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-camera-button.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-camera-button@2x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-camera-button@3x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-delete-button.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-delete-button@2x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-delete-button@3x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-no-connection.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-no-connection@2x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-powered-by-logo.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-powered-by-logo@2x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-powered-by-logo@3x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-screenshot-error.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HS-screenshot-error@2x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSChatBubbleBlue.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSChatBubbleBlue@2x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSChatBubbleBlue@3x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSChatBubbleWhite.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSChatBubbleWhite@2x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSChatBubbleWhite@3x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSConfirmBox.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSConfirmBox@2x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSTutorial.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSTutorial@2x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSTutorial@3x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSTutorialiPad.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSTutorialiPad@2x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSResources/HSTutorialiPad@3x.png"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/ar.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/cs.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/de.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/en.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/es.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/fr.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/hu.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/id.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/it.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/ja.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/ko.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/nl.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/pl.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/pt.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/ru.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/sl.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/th.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/tr.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/vi.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/zh-Hans.lproj"
  install_resource "Helpshift/helpshift-sdk-ios-v4.13.0/HSLocalization/zh-Hant.lproj"
  install_resource "${BUILT_PRODUCTS_DIR}/DMPasscode.bundle"
  install_resource "${BUILT_PRODUCTS_DIR}/LGSemiModalNavController.bundle"
fi

rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]]; then
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "$XCASSET_FILES" ]
then
  case "${TARGETED_DEVICE_FAMILY}" in
    1,2)
      TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
      ;;
    1)
      TARGET_DEVICE_ARGS="--target-device iphone"
      ;;
    2)
      TARGET_DEVICE_ARGS="--target-device ipad"
      ;;
    *)
      TARGET_DEVICE_ARGS="--target-device mac"
      ;;
  esac
  while read line; do XCASSET_FILES="$XCASSET_FILES '$line'"; done <<<$(find "$PWD" -name "*.xcassets" | egrep -v "^$PODS_ROOT")
  echo $XCASSET_FILES | xargs actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
