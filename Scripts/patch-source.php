#!/usr/bin/env php
<?php

function fullpath($file)
{
    return realpath(__DIR__.'/../'.$file);
}

function append_after_import($file, $append)
{
    $content = file_get_contents($file = fullpath($file));

    if (strpos($content, $append) !== false) {
        return;
    }

    $content = preg_replace(
        '/(#import\s+[^\s]+(\r?\n))(\r?\n)/',
        '${1}'.$append.'${2}${3}',
        $content,
        1
    );

    if ($content) {
        file_put_contents($file, $content);
    }
}

function remove_lines($file, $lines)
{
    $content = file_get_contents($file = fullpath($file));

    foreach ((array) $lines as $text) {
        $content = preg_replace('/'.preg_quote($text, '/').'\r?\n/', '', $content);
    }

    if ($content) {
        file_put_contents($file, $content);
    }
}

function replace_text($file, $search, $replace)
{
    $content = file_get_contents($file = fullpath($file));
    $content = str_replace($search, $replace, $content);
    file_put_contents($file, $content);
}

// Append `#import "FUHelpers.h"` to import `FUNSLocalizedString()` function.
foreach ([
    'FaceUnity/FULiveDemo/Modules/Beauty/FUAPIDemoBar/FUAPIDemoBar.m',
    'FaceUnity/FULiveDemo/Helpers/FUCamera.m',
    'FaceUnity/FULiveDemo/Modules/Beauty/FUAPIDemoBar/FUBeautyView.m',
    'FaceUnity/FULiveDemo/Modules/Beauty/FUAPIDemoBar/FUFilterView.m',
] as $file) {
    append_after_import($file, '#import "FUHelpers.h"');
}

// Remove unnecessary #import in the .h files
foreach ([
    'FaceUnity/FULiveDemo/Helpers/FUManager.h' => '#import "FURenderer.h"',
] as $file => $removes) {
    remove_lines($file, $removes);
}

replace_text(
    'FaceUnity/FULiveDemo/Helpers/FUManager.m',
    [
        '#import "authpack.h"',
        '[[FURenderer shareRenderer] setupWithData:nil dataSize:0 ardata:nil authPackage:&g_auth_package authSize:sizeof(g_auth_package) shouldCreateContext:YES];',
    ],
    [
        '#import "FUAuthData.h"',
        '[[FURenderer shareRenderer] setupWithData:nil dataSize:0 ardata:nil authPackage:FUGetAuthData() authSize:FUGetAuthDataLength() shouldCreateContext:YES];',
    ]
);
