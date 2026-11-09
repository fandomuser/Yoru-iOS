#!/usr/bin/env python3
"""
Generates a complete, standard Xcode project.pbxproj including all 78 Swift source files,
resources, configuration files, and the TDLibFramework.xcframework integration into Yoru.xcodeproj.
"""

import os
import hashlib

def make_id(seed: str) -> str:
    h = hashlib.md5(seed.encode('utf-8')).hexdigest()[:24].upper()
    return f"1A{h[2:]}"

def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    yoru_dir = os.path.join(root, "Yoru")
    
    swift_files = []
    for dirpath, _, filenames in os.walk(yoru_dir):
        for f in filenames:
            if f.endswith('.swift'):
                rel = os.path.relpath(os.path.join(dirpath, f), yoru_dir).replace('\\', '/')
                swift_files.append(rel)
    swift_files.sort()
    
    print(f"Discovered {len(swift_files)} Swift source files to add to PBXSourcesBuildPhase.")
    
    build_files = []
    file_refs = []
    sources_entries = []
    
    file_ref_map = {}
    
    for sf in swift_files:
        base_name = os.path.basename(sf)
        file_id = make_id(f"FILEREF_{sf}")
        build_id = make_id(f"BUILDFILE_{sf}")
        
        file_ref_map[sf] = file_id
        
        build_files.append(f"\t\t{build_id} /* {base_name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_id} /* {base_name} */; }};")
        file_refs.append(f"\t\t{file_id} /* {base_name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {base_name}; sourceTree = \"<group>\"; }};")
        sources_entries.append(f"\t\t\t\t{build_id} /* {base_name} in Sources */,")
    
    # Non-code resources & Framework
    info_plist_id = make_id("FILEREF_Info_plist")
    config_xcconfig_id = make_id("FILEREF_Config_xcconfig")
    assets_id = make_id("FILEREF_Assets_xcassets")
    assets_build_id = make_id("BUILDFILE_Assets_xcassets")
    
    tdlib_fw_fileref_id = make_id("FILEREF_TDLibFramework_xcframework")
    tdlib_fw_link_build_id = make_id("BUILDFILE_TDLibFramework_link")
    tdlib_fw_embed_build_id = make_id("BUILDFILE_TDLibFramework_embed")
    
    app_product_id = "1A0000012CD1000100000001"
    
    file_refs.append(f"\t\t{info_plist_id} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = \"<group>\"; }};")
    file_refs.append(f"\t\t{config_xcconfig_id} /* Config.xcconfig */ = {{isa = PBXFileReference; lastKnownFileType = text.xcconfig; path = Config.xcconfig; sourceTree = \"<group>\"; }};")
    file_refs.append(f"\t\t{assets_id} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = \"<group>\"; }};")
    file_refs.append(f"\t\t{tdlib_fw_fileref_id} /* TDLibFramework.xcframework */ = {{isa = PBXFileReference; lastKnownFileType = wrapper.xcframework; name = TDLibFramework.xcframework; path = Yoru/Frameworks/TDLibFramework.xcframework; sourceTree = SOURCE_ROOT; }};")
    
    build_files.append(f"\t\t{assets_build_id} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {assets_id} /* Assets.xcassets */; }};")
    build_files.append(f"\t\t{tdlib_fw_link_build_id} /* TDLibFramework.xcframework in Frameworks */ = {{isa = PBXBuildFile; fileRef = {tdlib_fw_fileref_id} /* TDLibFramework.xcframework */; }};")
    build_files.append(f"\t\t{tdlib_fw_embed_build_id} /* TDLibFramework.xcframework in Embed Frameworks */ = {{isa = PBXBuildFile; fileRef = {tdlib_fw_fileref_id} /* TDLibFramework.xcframework */; settings = {{ATTRIBUTES = (CodeSignOnCopy, RemoveHeadersOnCopy, ); }}; }};")
    
    # Hierarchy Generation
    dir_files = {}
    for sf in swift_files:
        d = os.path.dirname(sf)
        dir_files.setdefault(d, []).append(sf)
    
    groups = []
    
    all_dirs = set(dir_files.keys())
    expanded_dirs = set()
    for d in all_dirs:
        parts = d.split('/')
        for i in range(1, len(parts) + 1):
            expanded_dirs.add('/'.join(parts[:i]))
    
    sorted_dirs = sorted(list(expanded_dirs), key=lambda x: x.count('/'), reverse=True)
    
    dir_group_ids = {}
    for d in sorted_dirs:
        dir_group_ids[d] = make_id(f"GROUP_{d}")
    
    for d in sorted_dirs:
        gid = dir_group_ids[d]
        name = os.path.basename(d)
        child_dirs = [sub for sub in sorted_dirs if os.path.dirname(sub) == d]
        child_files = dir_files.get(d, [])
        
        children_lines = []
        for cd in sorted(child_dirs):
            c_gid = dir_group_ids[cd]
            c_name = os.path.basename(cd)
            children_lines.append(f"\t\t\t\t{c_gid} /* {c_name} */,")
        for cf in sorted(child_files):
            f_id = file_ref_map[cf]
            f_name = os.path.basename(cf)
            children_lines.append(f"\t\t\t\t{f_id} /* {f_name} */,")
            
        children_str = "\n".join(children_lines)
        groups.append(f"""\t\t{gid} /* {name} */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{children_str}
\t\t\t);
\t\t\tpath = {name};
\t\t\tsourceTree = "<group>";
\t\t}};""")

    # Resources group
    res_group_id = make_id("GROUP_Resources")
    groups.append(f"""\t\t{res_group_id} /* Resources */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{info_plist_id} /* Info.plist */,
\t\t\t\t{config_xcconfig_id} /* Config.xcconfig */,
\t\t\t\t{assets_id} /* Assets.xcassets */,
\t\t\t);
\t\t\tpath = Resources;
\t\t\tsourceTree = "<group>";
\t\t}};""")

    # Frameworks group inside Yoru
    fw_group_id = make_id("GROUP_Frameworks")
    groups.append(f"""\t\t{fw_group_id} /* Frameworks */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{tdlib_fw_fileref_id} /* TDLibFramework.xcframework */,
\t\t\t);
\t\t\tname = Frameworks;
\t\t\tsourceTree = "<group>";
\t\t}};""")
    
    # Top Yoru group
    yoru_top_dirs = [d for d in sorted_dirs if '/' not in d]
    top_children = []
    for td in sorted(yoru_top_dirs):
        top_children.append(f"\t\t\t\t{dir_group_ids[td]} /* {td} */,")
    top_children.append(f"\t\t\t\t{res_group_id} /* Resources */,")
    top_children.append(f"\t\t\t\t{fw_group_id} /* Frameworks */,")
    top_children_str = "\n".join(top_children)
    
    yoru_main_group_id = "1A0000212CD1000100000001"
    groups.append(f"""\t\t{yoru_main_group_id} /* Yoru */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{top_children_str}
\t\t\t);
\t\t\tpath = Yoru;
\t\t\tsourceTree = "<group>";
\t\t}};""")
    
    # Root group
    root_group_id = "1A0000202CD1000100000001"
    products_group_id = "1A0000222CD1000100000001"
    groups.append(f"""\t\t{products_group_id} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{app_product_id} /* Yoru.app */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = "<group>";
\t\t}};""")
    
    groups.append(f"""\t\t{root_group_id} = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{yoru_main_group_id} /* Yoru */,
\t\t\t\t{fw_group_id} /* Frameworks */,
\t\t\t\t{products_group_id} /* Products */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};""")

    build_files_str = "\n".join(build_files)
    file_refs_str = "\n".join(file_refs)
    groups_str = "\n".join(groups)
    sources_str = "\n".join(sources_entries)
    
    copy_files_phase_id = make_id("COPYFILES_EmbedFrameworks")
    
    pbxproj_content = f"""// !$*UTF8*$!
{{
\tarchiveVersion = 1;
\tclasses = {{
\t}};
\tobjectVersion = 56;
\tobjects = {{

/* Begin PBXBuildFile section */
{build_files_str}
/* End PBXBuildFile section */

/* Begin PBXCopyFilesBuildPhase section */
\t\t{copy_files_phase_id} /* Embed Frameworks */ = {{
\t\t\tisa = PBXCopyFilesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tdstPath = "";
\t\t\tdstSubfolderSpec = 10;
\t\t\tfiles = (
\t\t\t\t{tdlib_fw_embed_build_id} /* TDLibFramework.xcframework in Embed Frameworks */,
\t\t\t);
\t\t\tname = "Embed Frameworks";
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXCopyFilesBuildPhase section */

/* Begin PBXFileReference section */
\t\t{app_product_id} /* Yoru.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Yoru.app; sourceTree = BUILT_PRODUCTS_DIR; }};
{file_refs_str}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
\t\t1A0000102CD1000100000001 /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{tdlib_fw_link_build_id} /* TDLibFramework.xcframework in Frameworks */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
{groups_str}
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
\t\t1A0000302CD1000100000001 /* Yoru */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = 1A0000402CD1000100000001 /* Build configuration list for PBXNativeTarget "Yoru" */;
\t\t\tbuildPhases = (
\t\t\t\t1A0000502CD1000100000001 /* Sources */,
\t\t\t\t1A0000102CD1000100000001 /* Frameworks */,
\t\t\t\t1A0000602CD1000100000001 /* Resources */,
\t\t\t\t{copy_files_phase_id} /* Embed Frameworks */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = Yoru;
\t\t\tproductName = Yoru;
\t\t\tproductReference = {app_product_id} /* Yoru.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\t1A0000002CD1000100000001 /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastSwiftUpdateCheck = 1530;
\t\t\t\tLastUpgradeCheck = 1530;
\t\t\t\tTargetAttributes = {{
\t\t\t\t\t1A0000302CD1000100000001 = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 15.3;
\t\t\t\t\t}};
\t\t\t\t}};
\t\t\t}};
\t\t\tbuildConfigurationList = 1A0000702CD1000100000001 /* Build configuration list for PBXProject "Yoru" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = {root_group_id};
\t\t\tproductRefGroup = {products_group_id} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t1A0000302CD1000100000001 /* Yoru */,
\t\t\t);
\t\t}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
\t\t1A0000602CD1000100000001 /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{assets_build_id} /* Assets.xcassets in Resources */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t1A0000502CD1000100000001 /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{sources_str}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
\t\t1A0000802CD1000100000001 /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (
\t\t\t\t\t"DEBUG=1",
\t\t\t\t\t"$(inherited)",
\t\t\t\t);
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t\tSWIFT_VERSION = 5.10;
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t1A0000812CD1000100000001 /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tENABLE_NS_ASSERTIONS = NO;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";
\t\t\t\tSWIFT_VERSION = 5.10;
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t1A0000902CD1000100000001 /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbaseConfigurationReference = {config_xcconfig_id} /* Config.xcconfig */;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tFRAMEWORK_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"$(PROJECT_DIR)/Yoru/Frameworks",
\t\t\t\t);
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = Yoru/Resources/Info.plist;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 0.1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.yoru.client;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;\n\t\t\t\tSWIFT_VERSION = 5.10;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t1A0000912CD1000100000001 /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbaseConfigurationReference = {config_xcconfig_id} /* Config.xcconfig */;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tFRAMEWORK_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"$(PROJECT_DIR)/Yoru/Frameworks",
\t\t\t\t);
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = Yoru/Resources/Info.plist;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 0.1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.yoru.client;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;\n\t\t\t\tSWIFT_VERSION = 5.10;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t1A0000402CD1000100000001 /* Build configuration list for PBXNativeTarget "Yoru" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t1A0000902CD1000100000001 /* Debug */,
\t\t\t\t1A0000912CD1000100000001 /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t1A0000702CD1000100000001 /* Build configuration list for PBXProject "Yoru" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t1A0000802CD1000100000001 /* Debug */,
\t\t\t\t1A0000812CD1000100000001 /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
/* End XCConfigurationList section */

\t}};
\trootObject = 1A0000002CD1000100000001 /* Project object */;
}}
"""
    
    out_path = os.path.join(root, "Yoru.xcodeproj", "project.pbxproj")
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(pbxproj_content)
    
    print(f"Generated complete project.pbxproj at {out_path} with {len(swift_files)} source files and TDLibFramework.xcframework integration.")

if __name__ == "__main__":
    main()
