<?php
date_default_timezone_set('Asia/Manila');

$data = [
    "META" => [
        "APP_NAME" => "LOADER",
        "APP_VERSION_CODE" => 1,
        "VERSION_REASON" => "you are using the outdated app please wait for online update.",
        "UPDATE_URL" => "https://t.me/Sovereign_astral"
    ],
    "DATA" => [
        [
            "NAME" => "DAIKIE",
            "LOGO" => "https://raw.githubusercontent.com/daikiehaxs-web/Online/refs/heads/main/astral_logo.png",
            "DOWNLOAD" => "https://github.com/daikiehaxs-web/Online/raw/refs/heads/main/libDAKS.so",
            "GAME" => "com.garena.game.codm",
            "ARCH" => "64bit",
            "STATUS" => "ACTIVE"
        ],
        [
            "NAME" => "ASTRAL",
            "LOGO" => "https://raw.githubusercontent.com/daikiehaxs-web/Online/refs/heads/main/astral_logo.png",
            "DOWNLOAD" => "https://4amvip.x10.mx/ProtectMe/libAstral.so",
            "GAME" => "com.garena.game.codm",
            "ARCH" => "64bit",
            "STATUS" => "ACTIVE"
        ],
        [
            "NAME" => "TEST_LIB",
            "LOGO" => "https://raw.githubusercontent.com/daikiehaxs-web/Online/refs/heads/main/astral_logo.png",
            "DOWNLOAD" => "https://4amvip.x10.mx/ProtectMe/libTest.so",
            "GAME" => "com.garena.game.codm",
            "ARCH" => "64bit",
            "STATUS" => "ACTIVE"
        ],
    ]
];

header("Content-Type: application/json");
echo base64_encode(json_encode($data));