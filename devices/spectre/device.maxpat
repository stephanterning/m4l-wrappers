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
      922.0,
      169.0
    ],
    "openrect": [
      0.0,
      0.0,
      922.0,
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
    "devicewidth": 922.0,
    "description": "Wavesfactory Spectre VST3 stereo wrapper",
    "digest": "Spectre Wrapper",
    "tags": "VST3 Wavesfactory Spectre",
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
            0.1334056399132321,
            0.6616052060737527
          ],
          "presentation": 1,
          "presentation_rect": [
            0,
            0,
            922.0,
            169
          ],
          "patching_rect": [
            10,
            1100,
            922.0,
            169
          ]
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
              "parameter_longname": "Spectre state",
              "parameter_modmode": 0,
              "parameter_shortname": "Spectre state",
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
          "hint": "Gain before Spectre",
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
              "parameter_longname": "Drive",
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
          "hint": "Gain after Spectre",
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
            736.0,
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
              "parameter_longname": "Output Trim",
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
          "filename": "spectre-meter-v1.js",
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
          "filename": "spectre-meter-v1.js",
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
            801.0,
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
          "jspainterfile": "spectre-transparent.js",
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
            862.0,
            43.0,
            54.0,
            20.0
          ],
          "text": "Gain match",
          "texton": "Gain match",
          "varname": "match0",
          "active": 0
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
          "jspainterfile": "spectre-transparent.js",
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
            862.0,
            85.0,
            54.0,
            20.0
          ],
          "text": "Gain match",
          "texton": "Gain match",
          "varname": "match1",
          "active": 0
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
          "jspainterfile": "spectre-transparent.js",
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
            862.0,
            127.0,
            54.0,
            20.0
          ],
          "text": "Gain match",
          "texton": "Gain match",
          "varname": "match2",
          "active": 0
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
          "text": "dialog \"Spectre · VST3\" @mode 1",
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
          "id": "sp-face",
          "varname": "face",
          "maxclass": "v8ui",
          "patching_rect": [
            10,
            10,
            610,
            169
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "filename": "spectre-bands-v1.js",
          "background": 1,
          "presentation": 1,
          "presentation_rect": [
            123,
            0,
            610,
            169
          ],
          "hint": "Drag a band to set frequency and gain. Option-drag adjusts Q. Command-drag adjusts frequency. Right-click cycles saturation type; Command-right-click cycles backward."
        }
      },
      {
        "box": {
          "id": "sp-param0",
          "varname": "param0",
          "maxclass": "live.numbox",
          "patching_rect": [
            30,
            835,
            120,
            19
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
              "parameter_longname": "Band 1 Frequency",
              "parameter_shortname": "Band 1 Frequency",
              "parameter_type": 0,
              "parameter_mmin": 20.0,
              "parameter_mmax": 20000.0,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                42.08000096992389
              ],
              "parameter_unitstyle": 3
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param0ctl",
          "varname": "param0ctl",
          "maxclass": "newobj",
          "patching_rect": [
            30,
            858,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 0"
        }
      },
      {
        "box": {
          "id": "sp-param1",
          "varname": "param1",
          "maxclass": "live.numbox",
          "patching_rect": [
            180,
            835,
            120,
            19
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
              "parameter_longname": "Band 1 Gain",
              "parameter_shortname": "Band 1 Gain",
              "parameter_type": 0,
              "parameter_mmin": 0.0,
              "parameter_mmax": 12.0,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0.0
              ],
              "parameter_unitstyle": 4
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param1ctl",
          "varname": "param1ctl",
          "maxclass": "newobj",
          "patching_rect": [
            180,
            858,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 1"
        }
      },
      {
        "box": {
          "id": "sp-param2",
          "varname": "param2",
          "maxclass": "live.numbox",
          "patching_rect": [
            330,
            835,
            120,
            19
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
              "parameter_longname": "Band 1 Q",
              "parameter_shortname": "Band 1 Q",
              "parameter_type": 0,
              "parameter_mmin": 0.1,
              "parameter_mmax": 10.0,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0.7070000234991312
              ],
              "parameter_unitstyle": 1
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param2ctl",
          "varname": "param2ctl",
          "maxclass": "newobj",
          "patching_rect": [
            330,
            858,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 2"
        }
      },
      {
        "box": {
          "id": "sp-param3",
          "varname": "param3",
          "maxclass": "live.menu",
          "patching_rect": [
            480,
            835,
            120,
            19
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
              "parameter_longname": "Band 1 On",
              "parameter_shortname": "Band 1 On",
              "parameter_type": 2,
              "parameter_mmin": 0,
              "parameter_mmax": 1,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                1
              ],
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param3ctl",
          "varname": "param3ctl",
          "maxclass": "newobj",
          "patching_rect": [
            480,
            858,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 3"
        }
      },
      {
        "box": {
          "id": "sp-param4",
          "varname": "param4",
          "maxclass": "live.menu",
          "patching_rect": [
            630,
            835,
            120,
            19
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
              "parameter_longname": "Band 1 Color",
              "parameter_shortname": "Band 1 Color",
              "parameter_type": 2,
              "parameter_mmin": 0,
              "parameter_mmax": 10,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0
              ],
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Solid",
                "Warm",
                "Tube",
                "Tape",
                "Class B",
                "Diode",
                "Digital",
                "Bit",
                "Rectify",
                "Half Rectify",
                "Clean"
              ]
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param4ctl",
          "varname": "param4ctl",
          "maxclass": "newobj",
          "patching_rect": [
            630,
            858,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 4"
        }
      },
      {
        "box": {
          "id": "sp-param5",
          "varname": "param5",
          "maxclass": "live.menu",
          "patching_rect": [
            780,
            835,
            120,
            19
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
              "parameter_longname": "Band 1 Processing",
              "parameter_shortname": "Band 1 Processing",
              "parameter_type": 2,
              "parameter_mmin": 0,
              "parameter_mmax": 4,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0
              ],
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Stereo",
                "Left",
                "Right",
                "Mid",
                "Side"
              ]
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param5ctl",
          "varname": "param5ctl",
          "maxclass": "newobj",
          "patching_rect": [
            780,
            858,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 5"
        }
      },
      {
        "box": {
          "id": "sp-param6",
          "varname": "param6",
          "maxclass": "live.numbox",
          "patching_rect": [
            30,
            901,
            120,
            19
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
              "parameter_longname": "Band 2 Frequency",
              "parameter_shortname": "Band 2 Frequency",
              "parameter_type": 0,
              "parameter_mmin": 20.0,
              "parameter_mmax": 20000.0,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                164.0000025831755
              ],
              "parameter_unitstyle": 3
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param6ctl",
          "varname": "param6ctl",
          "maxclass": "newobj",
          "patching_rect": [
            30,
            924,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 6"
        }
      },
      {
        "box": {
          "id": "sp-param7",
          "varname": "param7",
          "maxclass": "live.numbox",
          "patching_rect": [
            180,
            901,
            120,
            19
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
              "parameter_longname": "Band 2 Gain",
              "parameter_shortname": "Band 2 Gain",
              "parameter_type": 0,
              "parameter_mmin": 0.0,
              "parameter_mmax": 12.0,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0.0
              ],
              "parameter_unitstyle": 4
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param7ctl",
          "varname": "param7ctl",
          "maxclass": "newobj",
          "patching_rect": [
            180,
            924,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 7"
        }
      },
      {
        "box": {
          "id": "sp-param8",
          "varname": "param8",
          "maxclass": "live.numbox",
          "patching_rect": [
            330,
            901,
            120,
            19
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
              "parameter_longname": "Band 2 Q",
              "parameter_shortname": "Band 2 Q",
              "parameter_type": 0,
              "parameter_mmin": 0.1,
              "parameter_mmax": 10.0,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0.7070000234991312
              ],
              "parameter_unitstyle": 1
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param8ctl",
          "varname": "param8ctl",
          "maxclass": "newobj",
          "patching_rect": [
            330,
            924,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 8"
        }
      },
      {
        "box": {
          "id": "sp-param9",
          "varname": "param9",
          "maxclass": "live.menu",
          "patching_rect": [
            480,
            901,
            120,
            19
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
              "parameter_longname": "Band 2 On",
              "parameter_shortname": "Band 2 On",
              "parameter_type": 2,
              "parameter_mmin": 0,
              "parameter_mmax": 1,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                1
              ],
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param9ctl",
          "varname": "param9ctl",
          "maxclass": "newobj",
          "patching_rect": [
            480,
            924,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 9"
        }
      },
      {
        "box": {
          "id": "sp-param10",
          "varname": "param10",
          "maxclass": "live.menu",
          "patching_rect": [
            630,
            901,
            120,
            19
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
              "parameter_longname": "Band 2 Color",
              "parameter_shortname": "Band 2 Color",
              "parameter_type": 2,
              "parameter_mmin": 0,
              "parameter_mmax": 10,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0
              ],
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Solid",
                "Warm",
                "Tube",
                "Tape",
                "Class B",
                "Diode",
                "Digital",
                "Bit",
                "Rectify",
                "Half Rectify",
                "Clean"
              ]
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param10ctl",
          "varname": "param10ctl",
          "maxclass": "newobj",
          "patching_rect": [
            630,
            924,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 10"
        }
      },
      {
        "box": {
          "id": "sp-param11",
          "varname": "param11",
          "maxclass": "live.menu",
          "patching_rect": [
            780,
            901,
            120,
            19
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
              "parameter_longname": "Band 2 Processing",
              "parameter_shortname": "Band 2 Processing",
              "parameter_type": 2,
              "parameter_mmin": 0,
              "parameter_mmax": 4,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0
              ],
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Stereo",
                "Left",
                "Right",
                "Mid",
                "Side"
              ]
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param11ctl",
          "varname": "param11ctl",
          "maxclass": "newobj",
          "patching_rect": [
            780,
            924,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 11"
        }
      },
      {
        "box": {
          "id": "sp-param12",
          "varname": "param12",
          "maxclass": "live.numbox",
          "patching_rect": [
            30,
            967,
            120,
            19
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
              "parameter_longname": "Band 3 Frequency",
              "parameter_shortname": "Band 3 Frequency",
              "parameter_type": 0,
              "parameter_mmin": 20.0,
              "parameter_mmax": 20000.0,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                632.5000626229526
              ],
              "parameter_unitstyle": 3
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param12ctl",
          "varname": "param12ctl",
          "maxclass": "newobj",
          "patching_rect": [
            30,
            990,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 12"
        }
      },
      {
        "box": {
          "id": "sp-param13",
          "varname": "param13",
          "maxclass": "live.numbox",
          "patching_rect": [
            180,
            967,
            120,
            19
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
              "parameter_longname": "Band 3 Gain",
              "parameter_shortname": "Band 3 Gain",
              "parameter_type": 0,
              "parameter_mmin": 0.0,
              "parameter_mmax": 12.0,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0.0
              ],
              "parameter_unitstyle": 4
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param13ctl",
          "varname": "param13ctl",
          "maxclass": "newobj",
          "patching_rect": [
            180,
            990,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 13"
        }
      },
      {
        "box": {
          "id": "sp-param14",
          "varname": "param14",
          "maxclass": "live.numbox",
          "patching_rect": [
            330,
            967,
            120,
            19
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
              "parameter_longname": "Band 3 Q",
              "parameter_shortname": "Band 3 Q",
              "parameter_type": 0,
              "parameter_mmin": 0.1,
              "parameter_mmax": 10.0,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0.7070000234991312
              ],
              "parameter_unitstyle": 1
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param14ctl",
          "varname": "param14ctl",
          "maxclass": "newobj",
          "patching_rect": [
            330,
            990,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 14"
        }
      },
      {
        "box": {
          "id": "sp-param15",
          "varname": "param15",
          "maxclass": "live.menu",
          "patching_rect": [
            480,
            967,
            120,
            19
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
              "parameter_longname": "Band 3 On",
              "parameter_shortname": "Band 3 On",
              "parameter_type": 2,
              "parameter_mmin": 0,
              "parameter_mmax": 1,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                1
              ],
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param15ctl",
          "varname": "param15ctl",
          "maxclass": "newobj",
          "patching_rect": [
            480,
            990,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 15"
        }
      },
      {
        "box": {
          "id": "sp-param16",
          "varname": "param16",
          "maxclass": "live.menu",
          "patching_rect": [
            630,
            967,
            120,
            19
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
              "parameter_longname": "Band 3 Color",
              "parameter_shortname": "Band 3 Color",
              "parameter_type": 2,
              "parameter_mmin": 0,
              "parameter_mmax": 10,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0
              ],
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Solid",
                "Warm",
                "Tube",
                "Tape",
                "Class B",
                "Diode",
                "Digital",
                "Bit",
                "Rectify",
                "Half Rectify",
                "Clean"
              ]
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param16ctl",
          "varname": "param16ctl",
          "maxclass": "newobj",
          "patching_rect": [
            630,
            990,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 16"
        }
      },
      {
        "box": {
          "id": "sp-param17",
          "varname": "param17",
          "maxclass": "live.menu",
          "patching_rect": [
            780,
            967,
            120,
            19
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
              "parameter_longname": "Band 3 Processing",
              "parameter_shortname": "Band 3 Processing",
              "parameter_type": 2,
              "parameter_mmin": 0,
              "parameter_mmax": 4,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0
              ],
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Stereo",
                "Left",
                "Right",
                "Mid",
                "Side"
              ]
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param17ctl",
          "varname": "param17ctl",
          "maxclass": "newobj",
          "patching_rect": [
            780,
            990,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 17"
        }
      },
      {
        "box": {
          "id": "sp-param18",
          "varname": "param18",
          "maxclass": "live.numbox",
          "patching_rect": [
            30,
            1033,
            120,
            19
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
              "parameter_longname": "Band 4 Frequency",
              "parameter_shortname": "Band 4 Frequency",
              "parameter_type": 0,
              "parameter_mmin": 20.0,
              "parameter_mmax": 20000.0,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                2459.9995023035603
              ],
              "parameter_unitstyle": 3
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param18ctl",
          "varname": "param18ctl",
          "maxclass": "newobj",
          "patching_rect": [
            30,
            1056,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 18"
        }
      },
      {
        "box": {
          "id": "sp-param19",
          "varname": "param19",
          "maxclass": "live.numbox",
          "patching_rect": [
            180,
            1033,
            120,
            19
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
              "parameter_longname": "Band 4 Gain",
              "parameter_shortname": "Band 4 Gain",
              "parameter_type": 0,
              "parameter_mmin": 0.0,
              "parameter_mmax": 12.0,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0.0
              ],
              "parameter_unitstyle": 4
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param19ctl",
          "varname": "param19ctl",
          "maxclass": "newobj",
          "patching_rect": [
            180,
            1056,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 19"
        }
      },
      {
        "box": {
          "id": "sp-param20",
          "varname": "param20",
          "maxclass": "live.numbox",
          "patching_rect": [
            330,
            1033,
            120,
            19
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
              "parameter_longname": "Band 4 Q",
              "parameter_shortname": "Band 4 Q",
              "parameter_type": 0,
              "parameter_mmin": 0.1,
              "parameter_mmax": 10.0,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0.7070000234991312
              ],
              "parameter_unitstyle": 1
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param20ctl",
          "varname": "param20ctl",
          "maxclass": "newobj",
          "patching_rect": [
            330,
            1056,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 20"
        }
      },
      {
        "box": {
          "id": "sp-param21",
          "varname": "param21",
          "maxclass": "live.menu",
          "patching_rect": [
            480,
            1033,
            120,
            19
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
              "parameter_longname": "Band 4 On",
              "parameter_shortname": "Band 4 On",
              "parameter_type": 2,
              "parameter_mmin": 0,
              "parameter_mmax": 1,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                1
              ],
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param21ctl",
          "varname": "param21ctl",
          "maxclass": "newobj",
          "patching_rect": [
            480,
            1056,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 21"
        }
      },
      {
        "box": {
          "id": "sp-param22",
          "varname": "param22",
          "maxclass": "live.menu",
          "patching_rect": [
            630,
            1033,
            120,
            19
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
              "parameter_longname": "Band 4 Color",
              "parameter_shortname": "Band 4 Color",
              "parameter_type": 2,
              "parameter_mmin": 0,
              "parameter_mmax": 10,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0
              ],
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Solid",
                "Warm",
                "Tube",
                "Tape",
                "Class B",
                "Diode",
                "Digital",
                "Bit",
                "Rectify",
                "Half Rectify",
                "Clean"
              ]
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param22ctl",
          "varname": "param22ctl",
          "maxclass": "newobj",
          "patching_rect": [
            630,
            1056,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 22"
        }
      },
      {
        "box": {
          "id": "sp-param23",
          "varname": "param23",
          "maxclass": "live.menu",
          "patching_rect": [
            780,
            1033,
            120,
            19
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
              "parameter_longname": "Band 4 Processing",
              "parameter_shortname": "Band 4 Processing",
              "parameter_type": 2,
              "parameter_mmin": 0,
              "parameter_mmax": 4,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0
              ],
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Stereo",
                "Left",
                "Right",
                "Mid",
                "Side"
              ]
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param23ctl",
          "varname": "param23ctl",
          "maxclass": "newobj",
          "patching_rect": [
            780,
            1056,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 23"
        }
      },
      {
        "box": {
          "id": "sp-param24",
          "varname": "param24",
          "maxclass": "live.numbox",
          "patching_rect": [
            30,
            1099,
            120,
            19
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
              "parameter_longname": "Band 5 Frequency",
              "parameter_shortname": "Band 5 Frequency",
              "parameter_type": 0,
              "parameter_mmin": 20.0,
              "parameter_mmax": 20000.0,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                9600.000806923503
              ],
              "parameter_unitstyle": 3
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param24ctl",
          "varname": "param24ctl",
          "maxclass": "newobj",
          "patching_rect": [
            30,
            1122,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 24"
        }
      },
      {
        "box": {
          "id": "sp-param25",
          "varname": "param25",
          "maxclass": "live.numbox",
          "patching_rect": [
            180,
            1099,
            120,
            19
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
              "parameter_longname": "Band 5 Gain",
              "parameter_shortname": "Band 5 Gain",
              "parameter_type": 0,
              "parameter_mmin": 0.0,
              "parameter_mmax": 12.0,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0.0
              ],
              "parameter_unitstyle": 4
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param25ctl",
          "varname": "param25ctl",
          "maxclass": "newobj",
          "patching_rect": [
            180,
            1122,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 25"
        }
      },
      {
        "box": {
          "id": "sp-param26",
          "varname": "param26",
          "maxclass": "live.numbox",
          "patching_rect": [
            330,
            1099,
            120,
            19
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
              "parameter_longname": "Band 5 Q",
              "parameter_shortname": "Band 5 Q",
              "parameter_type": 0,
              "parameter_mmin": 0.1,
              "parameter_mmax": 10.0,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0.7070000234991312
              ],
              "parameter_unitstyle": 1
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param26ctl",
          "varname": "param26ctl",
          "maxclass": "newobj",
          "patching_rect": [
            330,
            1122,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 26"
        }
      },
      {
        "box": {
          "id": "sp-param27",
          "varname": "param27",
          "maxclass": "live.menu",
          "patching_rect": [
            480,
            1099,
            120,
            19
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
              "parameter_longname": "Band 5 On",
              "parameter_shortname": "Band 5 On",
              "parameter_type": 2,
              "parameter_mmin": 0,
              "parameter_mmax": 1,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                1
              ],
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param27ctl",
          "varname": "param27ctl",
          "maxclass": "newobj",
          "patching_rect": [
            480,
            1122,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 27"
        }
      },
      {
        "box": {
          "id": "sp-param28",
          "varname": "param28",
          "maxclass": "live.menu",
          "patching_rect": [
            630,
            1099,
            120,
            19
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
              "parameter_longname": "Band 5 Color",
              "parameter_shortname": "Band 5 Color",
              "parameter_type": 2,
              "parameter_mmin": 0,
              "parameter_mmax": 10,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0
              ],
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Solid",
                "Warm",
                "Tube",
                "Tape",
                "Class B",
                "Diode",
                "Digital",
                "Bit",
                "Rectify",
                "Half Rectify",
                "Clean"
              ]
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param28ctl",
          "varname": "param28ctl",
          "maxclass": "newobj",
          "patching_rect": [
            630,
            1122,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 28"
        }
      },
      {
        "box": {
          "id": "sp-param29",
          "varname": "param29",
          "maxclass": "live.menu",
          "patching_rect": [
            780,
            1099,
            120,
            19
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
              "parameter_longname": "Band 5 Processing",
              "parameter_shortname": "Band 5 Processing",
              "parameter_type": 2,
              "parameter_mmin": 0,
              "parameter_mmax": 4,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0
              ],
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Stereo",
                "Left",
                "Right",
                "Mid",
                "Side"
              ]
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param29ctl",
          "varname": "param29ctl",
          "maxclass": "newobj",
          "patching_rect": [
            780,
            1122,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 29"
        }
      },
      {
        "box": {
          "id": "sp-param30",
          "varname": "param30",
          "maxclass": "live.numbox",
          "patching_rect": [
            30,
            1165,
            120,
            19
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
              "parameter_longname": "Spectre Input",
              "parameter_shortname": "Spectre Input",
              "parameter_type": 0,
              "parameter_mmin": -12.0,
              "parameter_mmax": 12.0,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0.0
              ],
              "parameter_unitstyle": 4
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param30ctl",
          "varname": "param30ctl",
          "maxclass": "newobj",
          "patching_rect": [
            30,
            1188,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 30"
        }
      },
      {
        "box": {
          "id": "sp-param31",
          "varname": "param31",
          "maxclass": "live.numbox",
          "patching_rect": [
            180,
            1165,
            120,
            19
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
              "parameter_longname": "Spectre Output",
              "parameter_shortname": "Spectre Output",
              "parameter_type": 0,
              "parameter_mmin": -12.0,
              "parameter_mmax": 12.0,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0.0
              ],
              "parameter_unitstyle": 4
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param31ctl",
          "varname": "param31ctl",
          "maxclass": "newobj",
          "patching_rect": [
            180,
            1188,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 31"
        }
      },
      {
        "box": {
          "id": "sp-param32",
          "varname": "param32",
          "maxclass": "live.numbox",
          "patching_rect": [
            330,
            1165,
            120,
            19
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
              "parameter_type": 0,
              "parameter_mmin": 0.0,
              "parameter_mmax": 100.0,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                50.0
              ],
              "parameter_unitstyle": 5
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param32ctl",
          "varname": "param32ctl",
          "maxclass": "newobj",
          "patching_rect": [
            330,
            1188,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 32"
        }
      },
      {
        "box": {
          "id": "sp-param33",
          "varname": "param33",
          "maxclass": "live.menu",
          "patching_rect": [
            480,
            1165,
            120,
            19
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
              "parameter_longname": "Input Compensation",
              "parameter_shortname": "Input Compensation",
              "parameter_type": 2,
              "parameter_mmin": 0,
              "parameter_mmax": 1,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0
              ],
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param33ctl",
          "varname": "param33ctl",
          "maxclass": "newobj",
          "patching_rect": [
            480,
            1188,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 33"
        }
      },
      {
        "box": {
          "id": "sp-param34",
          "varname": "param34",
          "maxclass": "live.menu",
          "patching_rect": [
            630,
            1165,
            120,
            19
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
              "parameter_longname": "Quality",
              "parameter_shortname": "Quality",
              "parameter_type": 2,
              "parameter_mmin": 0,
              "parameter_mmax": 2,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                1
              ],
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Normal",
                "Good",
                "Best"
              ]
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param34ctl",
          "varname": "param34ctl",
          "maxclass": "newobj",
          "patching_rect": [
            630,
            1188,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 34"
        }
      },
      {
        "box": {
          "id": "sp-param35",
          "varname": "param35",
          "maxclass": "live.menu",
          "patching_rect": [
            780,
            1165,
            120,
            19
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
              "parameter_longname": "De-Emphasis",
              "parameter_shortname": "De-Emphasis",
              "parameter_type": 2,
              "parameter_mmin": 0,
              "parameter_mmax": 1,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                1
              ],
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Disabled",
                "Enabled"
              ]
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param35ctl",
          "varname": "param35ctl",
          "maxclass": "newobj",
          "patching_rect": [
            780,
            1188,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 35"
        }
      },
      {
        "box": {
          "id": "sp-param36",
          "varname": "param36",
          "maxclass": "live.menu",
          "patching_rect": [
            30,
            1231,
            120,
            19
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
              "parameter_longname": "Mode",
              "parameter_shortname": "Mode",
              "parameter_type": 2,
              "parameter_mmin": 0,
              "parameter_mmax": 2,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0
              ],
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Subtle",
                "Medium",
                "Aggressive"
              ]
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param36ctl",
          "varname": "param36ctl",
          "maxclass": "newobj",
          "patching_rect": [
            30,
            1254,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 36"
        }
      },
      {
        "box": {
          "id": "sp-param37",
          "varname": "param37",
          "maxclass": "live.menu",
          "patching_rect": [
            180,
            1231,
            120,
            19
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
              "parameter_longname": "Processing",
              "parameter_shortname": "Processing",
              "parameter_type": 2,
              "parameter_mmin": 0,
              "parameter_mmax": 4,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0
              ],
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Stereo",
                "Left",
                "Right",
                "Mid",
                "Side"
              ]
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param37ctl",
          "varname": "param37ctl",
          "maxclass": "newobj",
          "patching_rect": [
            180,
            1254,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 37"
        }
      },
      {
        "box": {
          "id": "sp-param38",
          "varname": "param38",
          "maxclass": "live.menu",
          "patching_rect": [
            330,
            1231,
            120,
            19
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
              "parameter_longname": "Spectre Bypass",
              "parameter_shortname": "Spectre Bypass",
              "parameter_type": 2,
              "parameter_mmin": 0,
              "parameter_mmax": 1,
              "parameter_initial_enable": 1,
              "parameter_initial": [
                0
              ],
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          }
        }
      },
      {
        "box": {
          "id": "sp-param38ctl",
          "varname": "param38ctl",
          "maxclass": "newobj",
          "patching_rect": [
            330,
            1254,
            115,
            19
          ],
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "text": "prepend control 38"
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
          "text": "m4lwrappergainstage~ drive",
          "numinlets": 2,
          "numoutlets": 3
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
          "text": "m4lwrappergainstage~",
          "numinlets": 4,
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
            "sp-face",
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
            "sp-param0",
            0
          ],
          "destination": [
            "sp-param0ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param0ctl",
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
            "sp-param1",
            0
          ],
          "destination": [
            "sp-param1ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param1ctl",
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
            "sp-param2",
            0
          ],
          "destination": [
            "sp-param2ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param2ctl",
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
            "sp-param3",
            0
          ],
          "destination": [
            "sp-param3ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param3ctl",
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
            "sp-param4",
            0
          ],
          "destination": [
            "sp-param4ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param4ctl",
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
            "sp-param5",
            0
          ],
          "destination": [
            "sp-param5ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param5ctl",
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
            "sp-param6",
            0
          ],
          "destination": [
            "sp-param6ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param6ctl",
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
            "sp-param7",
            0
          ],
          "destination": [
            "sp-param7ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param7ctl",
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
            "sp-param8",
            0
          ],
          "destination": [
            "sp-param8ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param8ctl",
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
            "sp-param9",
            0
          ],
          "destination": [
            "sp-param9ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param9ctl",
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
            "sp-param10",
            0
          ],
          "destination": [
            "sp-param10ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param10ctl",
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
            "sp-param11",
            0
          ],
          "destination": [
            "sp-param11ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param11ctl",
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
            "sp-param12",
            0
          ],
          "destination": [
            "sp-param12ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param12ctl",
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
            "sp-param13",
            0
          ],
          "destination": [
            "sp-param13ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param13ctl",
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
            "sp-param14",
            0
          ],
          "destination": [
            "sp-param14ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param14ctl",
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
            "sp-param15",
            0
          ],
          "destination": [
            "sp-param15ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param15ctl",
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
            "sp-param16",
            0
          ],
          "destination": [
            "sp-param16ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param16ctl",
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
            "sp-param17",
            0
          ],
          "destination": [
            "sp-param17ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param17ctl",
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
            "sp-param18",
            0
          ],
          "destination": [
            "sp-param18ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param18ctl",
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
            "sp-param19",
            0
          ],
          "destination": [
            "sp-param19ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param19ctl",
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
            "sp-param20",
            0
          ],
          "destination": [
            "sp-param20ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param20ctl",
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
            "sp-param21",
            0
          ],
          "destination": [
            "sp-param21ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param21ctl",
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
            "sp-param22",
            0
          ],
          "destination": [
            "sp-param22ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param22ctl",
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
            "sp-param23",
            0
          ],
          "destination": [
            "sp-param23ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param23ctl",
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
            "sp-param24",
            0
          ],
          "destination": [
            "sp-param24ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param24ctl",
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
            "sp-param25",
            0
          ],
          "destination": [
            "sp-param25ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param25ctl",
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
            "sp-param26",
            0
          ],
          "destination": [
            "sp-param26ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param26ctl",
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
            "sp-param27",
            0
          ],
          "destination": [
            "sp-param27ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param27ctl",
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
            "sp-param28",
            0
          ],
          "destination": [
            "sp-param28ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param28ctl",
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
            "sp-param29",
            0
          ],
          "destination": [
            "sp-param29ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param29ctl",
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
            "sp-param30",
            0
          ],
          "destination": [
            "sp-param30ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param30ctl",
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
            "sp-param31",
            0
          ],
          "destination": [
            "sp-param31ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param31ctl",
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
            "sp-param32",
            0
          ],
          "destination": [
            "sp-param32ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param32ctl",
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
            "sp-param33",
            0
          ],
          "destination": [
            "sp-param33ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param33ctl",
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
            "sp-param34",
            0
          ],
          "destination": [
            "sp-param34ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param34ctl",
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
            "sp-param35",
            0
          ],
          "destination": [
            "sp-param35ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param35ctl",
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
            "sp-param36",
            0
          ],
          "destination": [
            "sp-param36ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param36ctl",
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
            "sp-param37",
            0
          ],
          "destination": [
            "sp-param37ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param37ctl",
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
            "sp-param38",
            0
          ],
          "destination": [
            "sp-param38ctl",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sp-param38ctl",
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
            0
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
            0
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
      }
    ],
    "parameters": {
      "ox-bankState": [
        "Spectre state",
        "Spectre state",
        0
      ],
      "ox-driveLink": [
        "Drive Link",
        "Link",
        0
      ],
      "ox-postOutput": [
        "Output Trim",
        "Post Gain",
        0
      ],
      "ox-preDrive": [
        "Drive",
        "Pre Gain",
        0
      ],
      "sp-param0": [
        "Band 1 Frequency",
        "Band 1 Frequency",
        0
      ],
      "sp-param1": [
        "Band 1 Gain",
        "Band 1 Gain",
        0
      ],
      "sp-param2": [
        "Band 1 Q",
        "Band 1 Q",
        0
      ],
      "sp-param3": [
        "Band 1 On",
        "Band 1 On",
        0
      ],
      "sp-param4": [
        "Band 1 Color",
        "Band 1 Color",
        0
      ],
      "sp-param5": [
        "Band 1 Processing",
        "Band 1 Processing",
        0
      ],
      "sp-param6": [
        "Band 2 Frequency",
        "Band 2 Frequency",
        0
      ],
      "sp-param7": [
        "Band 2 Gain",
        "Band 2 Gain",
        0
      ],
      "sp-param8": [
        "Band 2 Q",
        "Band 2 Q",
        0
      ],
      "sp-param9": [
        "Band 2 On",
        "Band 2 On",
        0
      ],
      "sp-param10": [
        "Band 2 Color",
        "Band 2 Color",
        0
      ],
      "sp-param11": [
        "Band 2 Processing",
        "Band 2 Processing",
        0
      ],
      "sp-param12": [
        "Band 3 Frequency",
        "Band 3 Frequency",
        0
      ],
      "sp-param13": [
        "Band 3 Gain",
        "Band 3 Gain",
        0
      ],
      "sp-param14": [
        "Band 3 Q",
        "Band 3 Q",
        0
      ],
      "sp-param15": [
        "Band 3 On",
        "Band 3 On",
        0
      ],
      "sp-param16": [
        "Band 3 Color",
        "Band 3 Color",
        0
      ],
      "sp-param17": [
        "Band 3 Processing",
        "Band 3 Processing",
        0
      ],
      "sp-param18": [
        "Band 4 Frequency",
        "Band 4 Frequency",
        0
      ],
      "sp-param19": [
        "Band 4 Gain",
        "Band 4 Gain",
        0
      ],
      "sp-param20": [
        "Band 4 Q",
        "Band 4 Q",
        0
      ],
      "sp-param21": [
        "Band 4 On",
        "Band 4 On",
        0
      ],
      "sp-param22": [
        "Band 4 Color",
        "Band 4 Color",
        0
      ],
      "sp-param23": [
        "Band 4 Processing",
        "Band 4 Processing",
        0
      ],
      "sp-param24": [
        "Band 5 Frequency",
        "Band 5 Frequency",
        0
      ],
      "sp-param25": [
        "Band 5 Gain",
        "Band 5 Gain",
        0
      ],
      "sp-param26": [
        "Band 5 Q",
        "Band 5 Q",
        0
      ],
      "sp-param27": [
        "Band 5 On",
        "Band 5 On",
        0
      ],
      "sp-param28": [
        "Band 5 Color",
        "Band 5 Color",
        0
      ],
      "sp-param29": [
        "Band 5 Processing",
        "Band 5 Processing",
        0
      ],
      "sp-param30": [
        "Spectre Input",
        "Spectre Input",
        0
      ],
      "sp-param31": [
        "Spectre Output",
        "Spectre Output",
        0
      ],
      "sp-param32": [
        "Mix",
        "Mix",
        0
      ],
      "sp-param33": [
        "Input Compensation",
        "Input Compensation",
        0
      ],
      "sp-param34": [
        "Quality",
        "Quality",
        0
      ],
      "sp-param35": [
        "De-Emphasis",
        "De-Emphasis",
        0
      ],
      "sp-param36": [
        "Mode",
        "Mode",
        0
      ],
      "sp-param37": [
        "Processing",
        "Processing",
        0
      ],
      "sp-param38": [
        "Spectre Bypass",
        "Spectre Bypass",
        0
      ],
      "parameterbanks": {
        "0": {
          "index": 0,
          "name": "Global",
          "parameters": [
            "Drive",
            "Output Trim",
            "Quality",
            "De-Emphasis",
            "Spectre Input",
            "Spectre Output",
            "Mix",
            "Mode"
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
          "name": "Band 1",
          "parameters": [
            "Band 1 Frequency",
            "Band 1 Gain",
            "Band 1 Q",
            "Band 1 On",
            "Band 1 Color",
            "Band 1 Processing",
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
        },
        "2": {
          "index": 2,
          "name": "Band 2",
          "parameters": [
            "Band 2 Frequency",
            "Band 2 Gain",
            "Band 2 Q",
            "Band 2 On",
            "Band 2 Color",
            "Band 2 Processing",
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
        },
        "3": {
          "index": 3,
          "name": "Band 3",
          "parameters": [
            "Band 3 Frequency",
            "Band 3 Gain",
            "Band 3 Q",
            "Band 3 On",
            "Band 3 Color",
            "Band 3 Processing",
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
        },
        "4": {
          "index": 4,
          "name": "Band 4",
          "parameters": [
            "Band 4 Frequency",
            "Band 4 Gain",
            "Band 4 Q",
            "Band 4 On",
            "Band 4 Color",
            "Band 4 Processing",
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
        },
        "5": {
          "index": 5,
          "name": "Band 5",
          "parameters": [
            "Band 5 Frequency",
            "Band 5 Gain",
            "Band 5 Q",
            "Band 5 On",
            "Band 5 Color",
            "Band 5 Processing",
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
        },
        "6": {
          "index": 6,
          "name": "Routing",
          "parameters": [
            "Drive Link",
            "Input Compensation",
            "Processing",
            "Spectre Bypass",
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
      "inherited_shortname": 1
    },
    "latency": 0,
    "is_mpe": 0,
    "external_mpe_tuning_enabled": 0,
    "minimum_live_version": "",
    "minimum_max_version": "",
    "platform_compatibility": 1,
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
    "oscreceiveudpport": 0
  }
}
