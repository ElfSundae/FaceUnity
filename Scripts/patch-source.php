#!/usr/bin/env php
<?php

function file_path($file)
{
    return file_exists($file) ? $file : realpath(__DIR__.'/../'.$file);
}

function process_file($file, $callback)
{
    if ($content = file_get_contents($file = file_path($file))) {
        if ($newContent = $callback($content, $file)) {
            if ($newContent != $content) {
                file_put_contents($file, $newContent);
            }
        }
    }
}

function remove_lines($file, $lines)
{
    $lines = (array) $lines;
    process_file($file, function ($content) use ($lines) {
        foreach ($lines as $text) {
            $content = preg_replace('/'.preg_quote($text, '/').'\r?\n/', '', $content);
        }

        return $content;
    });
}

function replace_text($file, $search, $replace)
{
    process_file($file, function ($content) use ($search, $replace) {
        return str_replace($search, $replace, $content);
    });
}

function append_after_import($file, $append)
{
    process_file($file, function ($content) use ($append) {
        if (strpos($content, $append) !== false) {
            return;
        }

        return preg_replace(
            '/(#import\s+[^\s]+(\r?\n))(\r?\n)/',
            '${1}'.$append.'${2}${3}',
            $content,
            1
        );
    });
}

// Remove unnecessary `#import`
foreach ([
    'FaceUnity/FULiveDemo/Helpers/FUManager.h' => '#import "FURenderer.h"',
    'FaceUnity/FULiveDemo/Helpers/FUManager.m' => '#import "FURenderer+header.h"',
    'FaceUnity/FULiveDemo/Modules/Beauty/FUAPIDemoBar/FUAPIDemoBar.m' => [
        '#import "MJExtension.h"',
        '#import "FUMakeupSupModel.h"',
    ],
] as $file => $removes) {
    remove_lines($file, $removes);
}

// Add prefix `fu_` for category methods: https://github.com/Faceunity/FULiveDemo/pull/45
// Fix #import for third packages
foreach (
    glob(file_path('FaceUnity/FULiveDemo/Modules/Beauty/FUAPIDemoBar').'/*.[hm]')
    as $file
) {
    replace_text($file, [
        'colorWithHexColorString:',
        'imageWithName:',
        '#import <SVProgressHUD.h>',
    ], [
        'fu_colorWithHexColorString:',
        'fu_imageWithName:',
        '#import <SVProgressHUD/SVProgressHUD.h>',
    ]);
}

// Use FUAuthData class instead of authpack.h
replace_text(
    'FaceUnity/FULiveDemo/Helpers/FUManager.m',
    [
        '#import "authpack.h"',
        ' authPackage:&g_auth_package authSize:sizeof(g_auth_package) ',
    ],
    [
        '#import "FUAuthData.h"',
        ' authPackage:FUGetAuthData() authSize:FUGetAuthDataLength() ',
    ]
);

// Append `#import "FUHelpers.h"` to import `FUNSLocalizedString()` function
// which originally defined in PrefixHeader.pch
foreach ([
    'FaceUnity/FULiveDemo/Modules/Beauty/FUAPIDemoBar/FUAPIDemoBar.m',
    'FaceUnity/FULiveDemo/Helpers/FUCamera.m',
    'FaceUnity/FULiveDemo/Modules/Beauty/FUAPIDemoBar/FUBeautyView.m',
    'FaceUnity/FULiveDemo/Modules/Beauty/FUAPIDemoBar/FUFilterView.m',
] as $file) {
    append_after_import($file, '#import "FUHelpers.h"');
}
