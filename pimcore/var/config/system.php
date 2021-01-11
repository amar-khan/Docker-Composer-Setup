<?php 

return [
    "general" => [
        "timezone" => "Asia/Bangkok",
        "path_variable" => "",
        "domain" => "",
        "redirect_to_maindomain" => FALSE,
        "language" => "en",
        "validLanguages" => "en,th",
        "fallbackLanguages" => [
            "en" => "",
            "th" => ""
        ],
        "defaultLanguage" => "",
        "loginscreencustomimage" => "",
        "disableusagestatistics" => FALSE,
        "debug_admin_translations" => FALSE,
        "devmode" => FALSE,
        "instanceIdentifier" => "",
        "show_cookie_notice" => FALSE
    ],
    "database" => [
        "params" => [
            "username" => "root",
            "password" => "root",
            "dbname" => "seller_db",
            "host" => "127.0.0.1",
            "port" => "3307"
        ]
    ],
    "documents" => [
        "versions" => [
            "days" => NULL,
            "steps" => 10
        ],
        "default_controller" => "default",
        "default_action" => "default",
        "error_pages" => [
            "default" => "/"
        ],
        "createredirectwhenmoved" => FALSE,
        "allowtrailingslash" => "no",
        "generatepreview" => TRUE
    ],
    "objects" => [
        "versions" => [
            "days" => NULL,
            "steps" => 10
        ]
    ],
    "assets" => [
        "versions" => [
            "days" => NULL,
            "steps" => 10
        ],
        "icc_rgb_profile" => "",
        "icc_cmyk_profile" => "",
        "hide_edit_image" => FALSE,
        "disable_tree_preview" => FALSE
    ],
    "services" => [
        "google" => [
            "client_id" => "",
            "email" => "",
            "simpleapikey" => "",
            "browserapikey" => ""
        ]
    ],
    "cache" => [
        "enabled" => FALSE,
        "lifetime" => NULL,
        "excludePatterns" => "",
        "excludeCookie" => ""
    ],
    "httpclient" => [
        "adapter" => "Socket",
        "proxy_host" => "",
        "proxy_port" => "",
        "proxy_user" => "",
        "proxy_pass" => ""
    ],
    "email" => [
        "sender" => [
            "name" => "",
            "email" => ""
        ],
        "return" => [
            "name" => "",
            "email" => ""
        ],
        "method" => "mail",
        "smtp" => [
            "host" => "",
            "port" => "",
            "ssl" => NULL,
            "name" => "",
            "auth" => [
                "method" => NULL,
                "username" => "",
                "password" => NULL
            ]
        ],
        "debug" => [
            "emailaddresses" => ""
        ]
    ],
    "newsletter" => [
        "sender" => [
            "name" => "",
            "email" => ""
        ],
        "return" => [
            "name" => "",
            "email" => ""
        ],
        "method" => "mail",
        "smtp" => [
            "host" => "",
            "port" => "",
            "ssl" => NULL,
            "name" => "",
            "auth" => [
                "method" => NULL,
                "username" => "",
                "password" => NULL
            ]
        ],
        "debug" => NULL,
        "usespecific" => FALSE
    ],
    "branding" => [
        "color_login_screen" => "",
        "color_admin_interface" => ""
    ],
    "webservice" => [
        "enabled" => TRUE
    ],
    "applicationlog" => [
        "mail_notification" => [
            "send_log_summary" => FALSE,
            "filter_priority" => NULL,
            "mail_receiver" => ""
        ],
        "archive_treshold" => "30",
        "archive_alternative_database" => ""
    ]
];

