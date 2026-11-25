{
  "patcher": {
    "fileversion": 1,
    "appversion": {
      "major": 9,
      "minor": 2,
      "revision": 1,
      "architecture": "x64",
      "modernui": 1
    },
    "classnamespace": "box",
    "rect": [
      134.0,
      164.0,
      818.0,
      169.0
    ],
    "openrect": [
      0.0,
      0.0,
      818.0,
      169.0
    ],
    "openrectmode": 0,
    "openinpresentation": 1,
    "default_fontsize": 10.0,
    "default_fontname": "Arial Bold",
    "gridsize": [
      8.0,
      8.0
    ],
    "boxanimatetime": 500,
    "devicewidth": 818.0,
    "description": "Soundtoys Decapitator VST3 stereo wrapper",
    "digest": "Decapitator Wrapper",
    "tags": "VST3 Soundtoys Decapitator",
    "boxes": [
      {
        "box": {
          "id": "warning-overlay",
          "varname": "warningOverlay",
          "maxclass": "v8ui",
          "filename": "wrapper-warning-overlay.js",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "jsarguments": [
            0.15036674816625917,
            0.6185819070904646
          ],
          "presentation": 1,
          "presentation_rect": [
            0,
            0,
            818.0,
            169.0
          ],
          "patching_rect": [
            10,
            1100,
            818.0,
            169.0
          ]
        }
      },
      {
        "box": {
          "background": 1,
          "filename": "decapitator-panel.js",
          "id": "ox-face",
          "maxclass": "v8ui",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "parameter_enable": 0,
          "patching_rect": [
            12.0,
            12.0,
            506,
            169.0
          ],
          "presentation": 1,
          "presentation_rect": [
            123.0,
            0.0,
            506,
            169.0
          ],
          "varname": "face"
        }
      },
      {
        "box": {
          "id": "ox-bankState",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 3,
          "outlettype": [
            "",
            "",
            ""
          ],
          "patching_rect": [
            370.0,
            655.0,
            250.0,
            20.0
          ],
          "restore": [
            "none"
          ],
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_invisible": 1,
              "parameter_longname": "Decapitator state",
              "parameter_modmode": 0,
              "parameter_shortname": "Decapitator state",
              "parameter_type": 3
            }
          },
          "saved_object_attributes": {
            "parameter_enable": 1,
            "parameter_mappable": 0
          },
          "text": "pattr bankState @parameter_enable 1 @thru 0",
          "varname": "bankState"
        }
      },
      {
        "box": {
          "id": "ox-in",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "outlettype": [
            "signal",
            "signal"
          ],
          "patching_rect": [
            15.0,
            320.0,
            70.0,
            20.0
          ],
          "text": "plugin~",
          "varname": "in"
        }
      },
      {
        "box": {
          "id": "ox-out",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "outlettype": [
            "signal",
            "signal"
          ],
          "patching_rect": [
            15.0,
            475.0,
            75.0,
            20.0
          ],
          "text": "plugout~",
          "varname": "out"
        }
      },
      {
        "box": {
          "filename": "none",
          "fontface": 0,
          "fontname": "<Monospaced>",
          "fontsize": 10.0,
          "id": "ox-ctrl",
          "maxclass": "v8.codebox",
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            ""
          ],
          "patching_rect": [
            350.0,
            319.0,
            300.0,
            114.0
          ],
          "saved_object_attributes": {
            "parameter_enable": 0
          },
          "varname": "ctrl"
        }
      },
      {
        "box": {
          "appearance": 3,
          "hint": "Gain before Decapitator",
          "id": "ox-preDrive",
          "maxclass": "live.dial",
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            "float"
          ],
          "parameter_enable": 1,
          "patching_rect": [
            59.0,
            110.0,
            62.0,
            63.0
          ],
          "presentation": 1,
          "presentation_rect": [
            59.0,
            51.0,
            62.0,
            63.0
          ],
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_longname": "Pre Gain",
              "parameter_mmax": 24.0,
              "parameter_mmin": -24.0,
              "parameter_modmode": 0,
              "parameter_shortname": "Pre Gain",
              "parameter_type": 0,
              "parameter_unitstyle": 4
            }
          },
          "varname": "preDrive"
        }
      },
      {
        "box": {
          "id": "ox-preDrivectl",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            59.0,
            726.0,
            137.0,
            20.0
          ],
          "text": "prepend drive",
          "varname": "preDrivectl"
        }
      },
      {
        "box": {
          "appearance": 3,
          "hint": "Gain after Decapitator",
          "id": "ox-postOutput",
          "maxclass": "live.dial",
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            "float"
          ],
          "parameter_enable": 1,
          "patching_rect": [
            444.0,
            110.0,
            62.0,
            63.0
          ],
          "presentation": 1,
          "presentation_rect": [
            632.0,
            51.0,
            62.0,
            63.0
          ],
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_longname": "Post Gain",
              "parameter_mmax": 24.0,
              "parameter_mmin": -24.0,
              "parameter_modmode": 0,
              "parameter_shortname": "Post Gain",
              "parameter_type": 0,
              "parameter_unitstyle": 4
            }
          },
          "varname": "postOutput"
        }
      },
      {
        "box": {
          "id": "ox-postOutputctl",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            444.0,
            726.0,
            137.0,
            20.0
          ],
          "text": "prepend outputTrim",
          "varname": "postOutputctl"
        }
      },
      {
        "box": {
          "appearance": 1,
          "fontsize": 10.0,
          "hint": "Offset Drive changes with the opposite change to Output.",
          "id": "ox-driveLink",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            ""
          ],
          "parameter_enable": 1,
          "patching_rect": [
            59.0,
            117.0,
            40.0,
            14.0
          ],
          "presentation": 1,
          "presentation_rect": [
            71.0,
            126.0,
            40.0,
            14.0
          ],
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_enum": [
                "val1",
                "val2"
              ],
              "parameter_initial": [
                0
              ],
              "parameter_initial_enable": 1,
              "parameter_longname": "Drive Link",
              "parameter_mmax": 1,
              "parameter_modmode": 0,
              "parameter_shortname": "Link",
              "parameter_type": 2
            }
          },
          "text": "Link",
          "texton": "Link",
          "varname": "driveLink"
        }
      },
      {
        "box": {
          "id": "ox-driveLinkCtl",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            299.0,
            726.0,
            156.0,
            20.0
          ],
          "text": "prepend driveLinkChanged",
          "varname": "driveLinkCtl"
        }
      },
      {
        "box": {
          "background": 1,
          "filename": "oxford-meter-peak.js",
          "hint": "Short-term LUFS, RMS and sample peak (dBFS). Click to reset both meters.",
          "id": "ox-inputMeter",
          "jsarguments": [
            0
          ],
          "maxclass": "jsui",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "parameter_enable": 0,
          "patching_rect": [
            12.0,
            12.0,
            56.0,
            169.0
          ],
          "presentation": 1,
          "presentation_rect": [
            0.0,
            0.0,
            56.0,
            169.0
          ],
          "varname": "inputMeter"
        }
      },
      {
        "box": {
          "background": 1,
          "filename": "oxford-meter-peak.js",
          "hint": "Short-term LUFS, RMS and sample peak (dBFS). Click to reset both meters.",
          "id": "ox-outputMeter",
          "jsarguments": [
            1
          ],
          "maxclass": "jsui",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "parameter_enable": 0,
          "patching_rect": [
            521.0,
            12.0,
            120.0,
            169.0
          ],
          "presentation": 1,
          "presentation_rect": [
            697.0,
            0.0,
            120.0,
            169.0
          ],
          "varname": "outputMeter"
        }
      },
      {
        "box": {
          "fontsize": 9.0,
          "hint": "Match output to input short-term LUFS",
          "id": "ox-match0",
          "jspainterfile": "oxford-transparent.js",
          "maxclass": "live.text",
          "mode": 0,
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            ""
          ],
          "parameter_enable": 0,
          "patching_rect": [
            701.0,
            475.0,
            65.0,
            20.0
          ],
          "presentation": 1,
          "presentation_rect": [
            758.0,
            43.0,
            54.0,
            20.0
          ],
          "text": "Gain match",
          "texton": "Gain match",
          "varname": "match0"
        }
      },
      {
        "box": {
          "id": "ox-match0ctl",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            771.0,
            475.0,
            105.0,
            20.0
          ],
          "text": "gainmatch 0",
          "varname": "match0ctl"
        }
      },
      {
        "box": {
          "fontsize": 9.0,
          "hint": "Match output to input RMS",
          "id": "ox-match1",
          "jspainterfile": "oxford-transparent.js",
          "maxclass": "live.text",
          "mode": 0,
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            ""
          ],
          "parameter_enable": 0,
          "patching_rect": [
            701.0,
            505.0,
            65.0,
            20.0
          ],
          "presentation": 1,
          "presentation_rect": [
            758.0,
            85.0,
            54.0,
            20.0
          ],
          "text": "Gain match",
          "texton": "Gain match",
          "varname": "match1"
        }
      },
      {
        "box": {
          "id": "ox-match1ctl",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            771.0,
            505.0,
            105.0,
            20.0
          ],
          "text": "gainmatch 1",
          "varname": "match1ctl"
        }
      },
      {
        "box": {
          "fontsize": 9.0,
          "hint": "Match output to input sample peak",
          "id": "ox-match2",
          "jspainterfile": "oxford-transparent.js",
          "maxclass": "live.text",
          "mode": 0,
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            ""
          ],
          "parameter_enable": 0,
          "patching_rect": [
            701.0,
            535.0,
            65.0,
            20.0
          ],
          "presentation": 1,
          "presentation_rect": [
            758.0,
            127.0,
            54.0,
            20.0
          ],
          "text": "Gain match",
          "texton": "Gain match",
          "varname": "match2"
        }
      },
      {
        "box": {
          "id": "ox-match2ctl",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            771.0,
            535.0,
            105.0,
            20.0
          ],
          "text": "gainmatch 2",
          "varname": "match2ctl"
        }
      },
      {
        "box": {
          "id": "ox-theme",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "list",
            "bang"
          ],
          "patching_rect": [
            690.0,
            699.0,
            149.0,
            20.0
          ],
          "text": "themecolor live_lcd_bg",
          "varname": "theme"
        }
      },
      {
        "box": {
          "id": "ox-redraw",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            842.0,
            699.0,
            60.0,
            20.0
          ],
          "text": "theme",
          "varname": "redraw"
        }
      },
      {
        "box": {
          "id": "ox-alert",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 3,
          "outlettype": [
            "",
            "bang",
            "bang"
          ],
          "patching_rect": [
            550.0,
            440.0,
            260.0,
            20.0
          ],
          "text": "dialog \"Decapitator · VST3\" @mode 1",
          "varname": "alert"
        }
      },
      {
        "box": {
          "id": "ox-init",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 3,
          "outlettype": [
            "bang",
            "int",
            "int"
          ],
          "patching_rect": [
            780.0,
            380.0,
            110.0,
            20.0
          ],
          "text": "live.thisdevice",
          "varname": "init"
        }
      },
      {
        "box": {
          "id": "ox-low",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            780.0,
            381.0,
            110.0,
            20.0
          ],
          "text": "deferlow",
          "varname": "low"
        }
      },
      {
        "box": {
          "id": "ox-end",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            "bang"
          ],
          "patching_rect": [
            780.0,
            382.0,
            110.0,
            20.0
          ],
          "text": "freebang",
          "varname": "end"
        }
      },
      {
        "box": {
          "id": "ox-go",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            890.0,
            373.0,
            93.0,
            20.0
          ],
          "text": "initialized",
          "varname": "go"
        }
      },
      {
        "box": {
          "id": "ox-finish",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            890.0,
            374.0,
            93.0,
            20.0
          ],
          "text": "cleanup",
          "varname": "finish"
        }
      },
      {
        "box": {
          "id": "decap-param0",
          "varname": "param0",
          "maxclass": "live.menu",
          "patching_rect": [
            20,
            510,
            100,
            18
          ],
          "numinlets": 1,
          "numoutlets": 3,
          "outlettype": [
            "int",
            "",
            "float"
          ],
          "parameter_enable": 1,
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Style",
              "parameter_shortname": "Style",
              "parameter_mmin": 0,
              "parameter_mmax": 4,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0
              ],
              "parameter_type": 2,
              "parameter_modmode": 0,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "A",
                "E",
                "N",
                "T",
                "P"
              ]
            }
          },
          "items": [
            "A",
            "E",
            "N",
            "T",
            "P"
          ]
        }
      },
      {
        "box": {
          "id": "decap-param0ctl",
          "varname": "param0ctl",
          "maxclass": "newobj",
          "text": "prepend control 0",
          "patching_rect": [
            125,
            510,
            80,
            18
          ]
        }
      },
      {
        "box": {
          "id": "decap-param1",
          "varname": "param1",
          "maxclass": "live.numbox",
          "patching_rect": [
            20,
            546,
            100,
            18
          ],
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            "float"
          ],
          "parameter_enable": 1,
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Drive",
              "parameter_shortname": "Drive",
              "parameter_mmin": 0,
              "parameter_mmax": 10,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0
              ],
              "parameter_type": 0,
              "parameter_modmode": 0,
              "parameter_unitstyle": 1
            }
          }
        }
      },
      {
        "box": {
          "id": "decap-param1ctl",
          "varname": "param1ctl",
          "maxclass": "newobj",
          "text": "prepend control 1",
          "patching_rect": [
            125,
            546,
            80,
            18
          ]
        }
      },
      {
        "box": {
          "id": "decap-param2",
          "varname": "param2",
          "maxclass": "live.menu",
          "patching_rect": [
            20,
            582,
            100,
            18
          ],
          "numinlets": 1,
          "numoutlets": 3,
          "outlettype": [
            "int",
            "",
            "float"
          ],
          "parameter_enable": 1,
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Punish",
              "parameter_shortname": "Punish",
              "parameter_mmin": 0,
              "parameter_mmax": 1,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0
              ],
              "parameter_type": 2,
              "parameter_modmode": 0,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "items": [
            "Off",
            "On"
          ]
        }
      },
      {
        "box": {
          "id": "decap-param2ctl",
          "varname": "param2ctl",
          "maxclass": "newobj",
          "text": "prepend control 2",
          "patching_rect": [
            125,
            582,
            80,
            18
          ]
        }
      },
      {
        "box": {
          "id": "decap-param3",
          "varname": "param3",
          "maxclass": "live.numbox",
          "patching_rect": [
            20,
            618,
            100,
            18
          ],
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            "float"
          ],
          "parameter_enable": 1,
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Low Cut",
              "parameter_shortname": "Low Cut",
              "parameter_mmin": 20,
              "parameter_mmax": 1000,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                20
              ],
              "parameter_type": 0,
              "parameter_modmode": 0,
              "parameter_unitstyle": 3
            }
          }
        }
      },
      {
        "box": {
          "id": "decap-param3ctl",
          "varname": "param3ctl",
          "maxclass": "newobj",
          "text": "prepend control 3",
          "patching_rect": [
            125,
            618,
            80,
            18
          ]
        }
      },
      {
        "box": {
          "id": "decap-param4",
          "varname": "param4",
          "maxclass": "live.numbox",
          "patching_rect": [
            20,
            654,
            100,
            18
          ],
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            "float"
          ],
          "parameter_enable": 1,
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Tone",
              "parameter_shortname": "Tone",
              "parameter_mmin": -12,
              "parameter_mmax": 12,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0
              ],
              "parameter_type": 0,
              "parameter_modmode": 0,
              "parameter_unitstyle": 4
            }
          }
        }
      },
      {
        "box": {
          "id": "decap-param4ctl",
          "varname": "param4ctl",
          "maxclass": "newobj",
          "text": "prepend control 4",
          "patching_rect": [
            125,
            654,
            80,
            18
          ]
        }
      },
      {
        "box": {
          "id": "decap-param5",
          "varname": "param5",
          "maxclass": "live.numbox",
          "patching_rect": [
            20,
            690,
            100,
            18
          ],
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            "float"
          ],
          "parameter_enable": 1,
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "High Cut",
              "parameter_shortname": "High Cut",
              "parameter_mmin": 1000,
              "parameter_mmax": 20000,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                20000
              ],
              "parameter_type": 0,
              "parameter_modmode": 0,
              "parameter_unitstyle": 3
            }
          }
        }
      },
      {
        "box": {
          "id": "decap-param5ctl",
          "varname": "param5ctl",
          "maxclass": "newobj",
          "text": "prepend control 5",
          "patching_rect": [
            125,
            690,
            80,
            18
          ]
        }
      },
      {
        "box": {
          "id": "decap-param6",
          "varname": "param6",
          "maxclass": "live.numbox",
          "patching_rect": [
            210,
            510,
            100,
            18
          ],
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            "float"
          ],
          "parameter_enable": 1,
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Mix",
              "parameter_shortname": "Mix",
              "parameter_mmin": 0,
              "parameter_mmax": 100,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                100
              ],
              "parameter_type": 0,
              "parameter_modmode": 0,
              "parameter_unitstyle": 5
            }
          }
        }
      },
      {
        "box": {
          "id": "decap-param6ctl",
          "varname": "param6ctl",
          "maxclass": "newobj",
          "text": "prepend control 6",
          "patching_rect": [
            315,
            510,
            80,
            18
          ]
        }
      },
      {
        "box": {
          "id": "decap-param7",
          "varname": "param7",
          "maxclass": "live.menu",
          "patching_rect": [
            210,
            546,
            100,
            18
          ],
          "numinlets": 1,
          "numoutlets": 3,
          "outlettype": [
            "int",
            "",
            "float"
          ],
          "parameter_enable": 1,
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "AutoGain",
              "parameter_shortname": "AutoGain",
              "parameter_mmin": 0,
              "parameter_mmax": 1,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                1
              ],
              "parameter_type": 2,
              "parameter_modmode": 0,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "items": [
            "Off",
            "On"
          ]
        }
      },
      {
        "box": {
          "id": "decap-param7ctl",
          "varname": "param7ctl",
          "maxclass": "newobj",
          "text": "prepend control 7",
          "patching_rect": [
            315,
            546,
            80,
            18
          ]
        }
      },
      {
        "box": {
          "id": "decap-param8",
          "varname": "param8",
          "maxclass": "live.menu",
          "patching_rect": [
            210,
            582,
            100,
            18
          ],
          "numinlets": 1,
          "numoutlets": 3,
          "outlettype": [
            "int",
            "",
            "float"
          ],
          "parameter_enable": 1,
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Thump",
              "parameter_shortname": "Thump",
              "parameter_mmin": 0,
              "parameter_mmax": 1,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0
              ],
              "parameter_type": 2,
              "parameter_modmode": 0,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "items": [
            "Off",
            "On"
          ]
        }
      },
      {
        "box": {
          "id": "decap-param8ctl",
          "varname": "param8ctl",
          "maxclass": "newobj",
          "text": "prepend control 8",
          "patching_rect": [
            315,
            582,
            80,
            18
          ]
        }
      },
      {
        "box": {
          "id": "decap-param9",
          "varname": "param9",
          "maxclass": "live.menu",
          "patching_rect": [
            210,
            618,
            100,
            18
          ],
          "numinlets": 1,
          "numoutlets": 3,
          "outlettype": [
            "int",
            "",
            "float"
          ],
          "parameter_enable": 1,
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "High Cut Slope",
              "parameter_shortname": "High Cut Slope",
              "parameter_mmin": 0,
              "parameter_mmax": 1,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0
              ],
              "parameter_type": 2,
              "parameter_modmode": 0,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Gentle",
                "Steep"
              ]
            }
          },
          "items": [
            "Gentle",
            "Steep"
          ]
        }
      },
      {
        "box": {
          "id": "decap-param9ctl",
          "varname": "param9ctl",
          "maxclass": "newobj",
          "text": "prepend control 9",
          "patching_rect": [
            315,
            618,
            80,
            18
          ]
        }
      },
      {
        "box": {
          "id": "decap-param10",
          "varname": "param10",
          "maxclass": "live.numbox",
          "patching_rect": [
            210,
            654,
            100,
            18
          ],
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            "float"
          ],
          "parameter_enable": 1,
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "OutputTrim",
              "parameter_shortname": "OutputTrim",
              "parameter_mmin": -24,
              "parameter_mmax": 0,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0
              ],
              "parameter_type": 0,
              "parameter_modmode": 0,
              "parameter_unitstyle": 4
            }
          }
        }
      },
      {
        "box": {
          "id": "decap-param10ctl",
          "varname": "param10ctl",
          "maxclass": "newobj",
          "text": "prepend control 10",
          "patching_rect": [
            315,
            654,
            80,
            18
          ]
        }
      },
      {
        "box": {
          "id": "maxPlugin",
          "varname": "maxPlugin",
          "maxclass": "newobj",
          "patching_rect": [
            320,
            1230,
            195,
            22
          ],
          "text": "vst~ 2 2 @prefer VST3 @autosave 0",
          "numinlets": 2,
          "numoutlets": 8
        }
      },
      {
        "box": {
          "id": "driveRamp",
          "varname": "driveRamp",
          "maxclass": "newobj",
          "patching_rect": [
            65,
            1150,
            195,
            22
          ],
          "text": "p preGain",
          "numinlets": 3,
          "numoutlets": 2
        }
      },
      {
        "box": {
          "id": "wrapperOutput",
          "varname": "wrapperOutput",
          "maxclass": "newobj",
          "patching_rect": [
            210,
            1280,
            195,
            22
          ],
          "text": "p postGainAndMeter",
          "numinlets": 5,
          "numoutlets": 3
        }
      },
      {
        "box": {
          "id": "maxHostControl",
          "varname": "maxHostControl",
          "maxclass": "v8.codebox",
          "patching_rect": [
            500,
            1230,
            195,
            22
          ],
          "numinlets": 3,
          "numoutlets": 4
        }
      },
      {
        "box": {
          "id": "audioStatus",
          "varname": "audioStatus",
          "maxclass": "newobj",
          "patching_rect": [
            90,
            1190,
            195,
            22
          ],
          "text": "dspstate~"
        }
      },
      {
        "box": {
          "id": "latencyRefresh",
          "varname": "latencyRefresh",
          "maxclass": "message",
          "patching_rect": [
            90,
            1218,
            195,
            22
          ],
          "text": "refreshLatency"
        }
      }
    ],
    "lines": [
      {
        "patchline": {
          "destination": [
            "ox-alert",
            0
          ],
          "source": [
            "ox-ctrl",
            1
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-driveLinkCtl",
            0
          ],
          "source": [
            "ox-driveLink",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-ctrl",
            0
          ],
          "source": [
            "ox-driveLinkCtl",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-finish",
            0
          ],
          "source": [
            "ox-end",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-ctrl",
            0
          ],
          "source": [
            "ox-finish",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-ctrl",
            0
          ],
          "source": [
            "ox-go",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-low",
            0
          ],
          "source": [
            "ox-init",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-ctrl",
            0
          ],
          "source": [
            "ox-inputMeter",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-go",
            0
          ],
          "source": [
            "ox-low",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-match0ctl",
            0
          ],
          "source": [
            "ox-match0",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-ctrl",
            0
          ],
          "source": [
            "ox-match0ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-match1ctl",
            0
          ],
          "source": [
            "ox-match1",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-ctrl",
            0
          ],
          "source": [
            "ox-match1ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-match2ctl",
            0
          ],
          "source": [
            "ox-match2",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-ctrl",
            0
          ],
          "source": [
            "ox-match2ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-ctrl",
            0
          ],
          "source": [
            "ox-outputMeter",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-postOutputctl",
            0
          ],
          "source": [
            "ox-postOutput",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-ctrl",
            0
          ],
          "source": [
            "ox-postOutputctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-preDrivectl",
            0
          ],
          "source": [
            "ox-preDrive",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-ctrl",
            0
          ],
          "source": [
            "ox-preDrivectl",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-inputMeter",
            0
          ],
          "order": 1,
          "source": [
            "ox-redraw",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-outputMeter",
            0
          ],
          "order": 0,
          "source": [
            "ox-redraw",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-redraw",
            0
          ],
          "source": [
            "ox-theme",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "ox-face",
            0
          ],
          "destination": [
            "ox-ctrl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "decap-param0",
            0
          ],
          "destination": [
            "decap-param0ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "decap-param0ctl",
            0
          ],
          "destination": [
            "ox-ctrl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "decap-param1",
            0
          ],
          "destination": [
            "decap-param1ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "decap-param1ctl",
            0
          ],
          "destination": [
            "ox-ctrl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "decap-param2",
            0
          ],
          "destination": [
            "decap-param2ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "decap-param2ctl",
            0
          ],
          "destination": [
            "ox-ctrl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "decap-param3",
            0
          ],
          "destination": [
            "decap-param3ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "decap-param3ctl",
            0
          ],
          "destination": [
            "ox-ctrl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "decap-param4",
            0
          ],
          "destination": [
            "decap-param4ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "decap-param4ctl",
            0
          ],
          "destination": [
            "ox-ctrl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "decap-param5",
            0
          ],
          "destination": [
            "decap-param5ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "decap-param5ctl",
            0
          ],
          "destination": [
            "ox-ctrl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "decap-param6",
            0
          ],
          "destination": [
            "decap-param6ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "decap-param6ctl",
            0
          ],
          "destination": [
            "ox-ctrl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "decap-param7",
            0
          ],
          "destination": [
            "decap-param7ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "decap-param7ctl",
            0
          ],
          "destination": [
            "ox-ctrl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "decap-param8",
            0
          ],
          "destination": [
            "decap-param8ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "decap-param8ctl",
            0
          ],
          "destination": [
            "ox-ctrl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "decap-param9",
            0
          ],
          "destination": [
            "decap-param9ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "decap-param9ctl",
            0
          ],
          "destination": [
            "ox-ctrl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "decap-param10",
            0
          ],
          "destination": [
            "decap-param10ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "decap-param10ctl",
            0
          ],
          "destination": [
            "ox-ctrl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "warning-overlay",
            0
          ],
          "destination": [
            "ox-ctrl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "ox-in",
            0
          ],
          "destination": [
            "driveRamp",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "driveRamp",
            0
          ],
          "destination": [
            "maxPlugin",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "ox-in",
            0
          ],
          "destination": [
            "wrapperOutput",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "maxPlugin",
            0
          ],
          "destination": [
            "wrapperOutput",
            2
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "wrapperOutput",
            0
          ],
          "destination": [
            "ox-out",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "ox-in",
            1
          ],
          "destination": [
            "driveRamp",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "driveRamp",
            1
          ],
          "destination": [
            "maxPlugin",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "ox-in",
            1
          ],
          "destination": [
            "wrapperOutput",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "maxPlugin",
            1
          ],
          "destination": [
            "wrapperOutput",
            3
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "wrapperOutput",
            1
          ],
          "destination": [
            "ox-out",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "ox-ctrl",
            0
          ],
          "destination": [
            "maxHostControl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "maxHostControl",
            0
          ],
          "destination": [
            "maxPlugin",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "maxHostControl",
            1
          ],
          "destination": [
            "ox-ctrl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "maxHostControl",
            2
          ],
          "destination": [
            "driveRamp",
            2
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "maxHostControl",
            3
          ],
          "destination": [
            "wrapperOutput",
            4
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "maxPlugin",
            2
          ],
          "destination": [
            "maxHostControl",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "maxPlugin",
            3
          ],
          "destination": [
            "maxHostControl",
            2
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "wrapperOutput",
            2
          ],
          "destination": [
            "ox-ctrl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "ox-in",
            0
          ],
          "destination": [
            "audioStatus",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "audioStatus",
            1
          ],
          "destination": [
            "latencyRefresh",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "latencyRefresh",
            0
          ],
          "destination": [
            "maxHostControl",
            0
          ]
        }
      }
    ],
    "parameters": {
      "ox-bankState": [
        "Decapitator state",
        "Decapitator state",
        0
      ],
      "ox-driveLink": [
        "Drive Link",
        "Link",
        0
      ],
      "ox-postOutput": [
        "Post Gain",
        "Post Gain",
        0
      ],
      "ox-preDrive": [
        "Pre Gain",
        "Pre Gain",
        0
      ],
      "parameterbanks": {
        "0": {
          "index": 0,
          "name": "Decapitator",
          "parameters": [
            "Style",
            "Drive",
            "Punish",
            "Low Cut",
            "Tone",
            "High Cut",
            "Mix",
            "AutoGain"
          ],
          "buttons": [
            "-",
            "-",
            "-",
            "-",
            "-",
            "-",
            "-",
            "-"
          ]
        },
        "1": {
          "index": 1,
          "name": "Trim and filters",
          "parameters": [
            "Thump",
            "High Cut Slope",
            "OutputTrim",
            "-",
            "-",
            "-",
            "-",
            "-"
          ],
          "buttons": [
            "-",
            "-",
            "-",
            "-",
            "-",
            "-",
            "-",
            "-"
          ]
        }
      },
      "inherited_shortname": 1,
      "decap-param0": [
        "Style",
        "Style",
        0
      ],
      "decap-param1": [
        "Drive",
        "Drive",
        0
      ],
      "decap-param2": [
        "Punish",
        "Punish",
        0
      ],
      "decap-param3": [
        "Low Cut",
        "Low Cut",
        0
      ],
      "decap-param4": [
        "Tone",
        "Tone",
        0
      ],
      "decap-param5": [
        "High Cut",
        "High Cut",
        0
      ],
      "decap-param6": [
        "Mix",
        "Mix",
        0
      ],
      "decap-param7": [
        "AutoGain",
        "AutoGain",
        0
      ],
      "decap-param8": [
        "Thump",
        "Thump",
        0
      ],
      "decap-param9": [
        "High Cut Slope",
        "High Cut Slope",
        0
      ],
      "decap-param10": [
        "OutputTrim",
        "OutputTrim",
        0
      ]
    },
    "latency": 0,
    "is_mpe": 0,
    "external_mpe_tuning_enabled": 0,
    "minimum_live_version": "",
    "minimum_max_version": "",
    "platform_compatibility": 0,
    "project": {
      "version": 1,
      "creationdate": 3590052493,
      "modificationdate": 3590052493,
      "viewrect": [
        0.0,
        0.0,
        300.0,
        500.0
      ],
      "autoorganize": 1,
      "hideprojectwindow": 1,
      "showdependencies": 1,
      "autolocalize": 0,
      "contents": {
        "patchers": {}
      },
      "layout": {},
      "searchpath": {},
      "detailsvisible": 0,
      "amxdtype": 1633771873,
      "readonly": 0,
      "devpathtype": 0,
      "devpath": ".",
      "sortmode": 0,
      "viewmode": 0,
      "includepackages": 0
    },
    "autosave": 0,
    "editing_bgcolor": [
      0.12,
      0.15,
      0.19,
      1.0
    ],
    "saved_attribute_attributes": {
      "editing_bgcolor": {
        "expression": ""
      }
    },
    "oscreceiveudpport": 0,
    "dependency_cache": []
  }
}
