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
      710.0,
      169.0
    ],
    "openrect": [
      0.0,
      0.0,
      710.0,
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
    "devicewidth": 710.0,
    "description": "Sonnox Oxford Inflator VST3 · stereo",
    "digest": "Oxford Inflator",
    "tags": "VST3 Sonnox",
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
            0.19523809523809524,
            0.5047619047619047
          ],
          "presentation": 1,
          "presentation_rect": [
            0,
            0,
            710.0,
            169.0
          ],
          "patching_rect": [
            10,
            1100,
            630.0,
            169.0
          ],
          "annotation": "If the VST3 is missing or fails to load, click Retry to try loading it again. When the plug-in editor is open, click the shaded area to close it.",
          "annotation_name": "Plug-in status"
        }
      },
      {
        "box": {
          "background": 1,
          "filename": "oxford-panel-v1.js",
          "id": "ox-face",
          "ignoreclick": 1,
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
            318.0,
            169.0
          ],
          "presentation": 1,
          "presentation_rect": [
            163.0,
            0.0,
            318.0,
            169.0
          ],
          "varname": "face"
        }
      },
      {
        "box": {
          "fontsize": 11.0,
          "id": "obj-8",
          "jspainterfile": "oxford-transparent.js",
          "maxclass": "live.slider",
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            "float"
          ],
          "parameter_enable": 1,
          "patching_rect": [
            5.0,
            29.0,
            54.0,
            132.0
          ],
          "presentation": 1,
          "presentation_rect": [
            168.0,
            29.0,
            54.0,
            132.0
          ],
          "saved_attribute_attributes": {
            "textcolor": {
              "expression": ""
            },
            "trioncolor": {
              "expression": ""
            },
            "valueof": {
              "parameter_initial": [
                0
              ],
              "parameter_initial_enable": 1,
              "parameter_longname": "Input Gain",
              "parameter_mmax": 12.0,
              "parameter_mmin": -6.0,
              "parameter_modmode": 0,
              "parameter_shortname": "Input",
              "parameter_type": 0,
              "parameter_unitstyle": 4
            }
          },
          "textcolor": [
            0.91,
            0.94,
            0.98,
            1.0
          ],
          "trioncolor": [
            0.45,
            0.77,
            0.87,
            1.0
          ],
          "varname": "input",
          "annotation": "Adjusts the signal level feeding Oxford Inflator's own processing.",
          "annotation_name": "Input Gain"
        }
      },
      {
        "box": {
          "id": "ox-ctl0",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            15.0,
            216.0,
            117.0,
            20.0
          ],
          "text": "prepend control 0",
          "varname": "ctl0"
        }
      },
      {
        "box": {
          "fontsize": 11.0,
          "id": "obj-10",
          "jspainterfile": "oxford-transparent.js",
          "maxclass": "live.slider",
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            "float"
          ],
          "parameter_enable": 1,
          "patching_rect": [
            67.0,
            29.0,
            54.0,
            132.0
          ],
          "presentation": 1,
          "presentation_rect": [
            230.0,
            29.0,
            54.0,
            132.0
          ],
          "saved_attribute_attributes": {
            "textcolor": {
              "expression": ""
            },
            "trioncolor": {
              "expression": ""
            },
            "valueof": {
              "parameter_initial": [
                0
              ],
              "parameter_initial_enable": 1,
              "parameter_longname": "Effect",
              "parameter_mmax": 100.0,
              "parameter_modmode": 0,
              "parameter_shortname": "Effect",
              "parameter_type": 0,
              "parameter_unitstyle": 5
            }
          },
          "textcolor": [
            0.91,
            0.94,
            0.98,
            1.0
          ],
          "trioncolor": [
            0.45,
            0.77,
            0.87,
            1.0
          ],
          "varname": "amount",
          "annotation": "Sets the amount of harmonic enhancement applied by Oxford Inflator.",
          "annotation_name": "Effect"
        }
      },
      {
        "box": {
          "id": "ox-ctl1",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            144.0,
            216.0,
            117.0,
            20.0
          ],
          "text": "prepend control 1",
          "varname": "ctl1"
        }
      },
      {
        "box": {
          "fontsize": 11.0,
          "id": "obj-12",
          "jspainterfile": "oxford-transparent.js",
          "maxclass": "live.slider",
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            "float"
          ],
          "parameter_enable": 1,
          "patching_rect": [
            195.0,
            29.0,
            54.0,
            132.0
          ],
          "presentation": 1,
          "presentation_rect": [
            358.0,
            29.0,
            54.0,
            132.0
          ],
          "saved_attribute_attributes": {
            "textcolor": {
              "expression": ""
            },
            "trioncolor": {
              "expression": ""
            },
            "valueof": {
              "parameter_initial": [
                0
              ],
              "parameter_initial_enable": 1,
              "parameter_longname": "Curve",
              "parameter_mmax": 50.0,
              "parameter_mmin": -50.0,
              "parameter_modmode": 0,
              "parameter_shortname": "Curve",
              "parameter_type": 0,
              "parameter_unitstyle": 1
            }
          },
          "textcolor": [
            0.91,
            0.94,
            0.98,
            1.0
          ],
          "trioncolor": [
            0.45,
            0.77,
            0.87,
            1.0
          ],
          "varname": "curve",
          "annotation": "Changes the harmonic character of the effect.",
          "annotation_name": "Curve"
        }
      },
      {
        "box": {
          "id": "ox-ctl2",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            273.0,
            216.0,
            117.0,
            20.0
          ],
          "text": "prepend control 2",
          "varname": "ctl2"
        }
      },
      {
        "box": {
          "fontsize": 11.0,
          "id": "obj-14",
          "jspainterfile": "oxford-transparent.js",
          "maxclass": "live.slider",
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            "float"
          ],
          "parameter_enable": 1,
          "patching_rect": [
            259.0,
            29.0,
            54.0,
            132.0
          ],
          "presentation": 1,
          "presentation_rect": [
            422.0,
            29.0,
            54.0,
            132.0
          ],
          "saved_attribute_attributes": {
            "textcolor": {
              "expression": ""
            },
            "trioncolor": {
              "expression": ""
            },
            "valueof": {
              "parameter_initial": [
                0
              ],
              "parameter_initial_enable": 1,
              "parameter_longname": "Output Gain",
              "parameter_mmax": 0.0,
              "parameter_mmin": -12.0,
              "parameter_modmode": 0,
              "parameter_shortname": "Output",
              "parameter_type": 0,
              "parameter_unitstyle": 4
            }
          },
          "textcolor": [
            0.91,
            0.94,
            0.98,
            1.0
          ],
          "trioncolor": [
            0.45,
            0.77,
            0.87,
            1.0
          ],
          "varname": "output",
          "annotation": "Adjusts the level leaving Oxford Inflator before the wrapper's Post Gain and output compensation.",
          "annotation_name": "Output Gain"
        }
      },
      {
        "box": {
          "id": "ox-ctl3",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            402.0,
            216.0,
            117.0,
            20.0
          ],
          "text": "prepend control 3",
          "varname": "ctl3"
        }
      },
      {
        "box": {
          "activebgoncolor": [
            0.3,
            0.55,
            0.6,
            1.0
          ],
          "fontsize": 11.0,
          "id": "obj-16",
          "jspainterfile": "oxford-transparent.js",
          "maxclass": "live.toggle",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            "int"
          ],
          "parameter_enable": 1,
          "patching_rect": [
            129.0,
            130.0,
            58.0,
            26.0
          ],
          "presentation": 1,
          "presentation_rect": [
            292.0,
            130.0,
            58.0,
            26.0
          ],
          "saved_attribute_attributes": {
            "activebgoncolor": {
              "expression": ""
            },
            "valueof": {
              "parameter_enum": [
                "Off",
                "On"
              ],
              "parameter_initial": [
                1
              ],
              "parameter_initial_enable": 1,
              "parameter_longname": "Effect In",
              "parameter_mmax": 1,
              "parameter_modmode": 0,
              "parameter_shortname": "Effect In",
              "parameter_type": 2,
              "parameter_unitstyle": 9
            }
          },
          "varname": "effectIn",
          "annotation": "Switches Oxford Inflator's enhancement on or off.",
          "annotation_name": "Effect In"
        }
      },
      {
        "box": {
          "id": "ox-ctl4",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            15.0,
            246.0,
            117.0,
            20.0
          ],
          "text": "prepend control 4",
          "varname": "ctl4"
        }
      },
      {
        "box": {
          "activebgoncolor": [
            0.3,
            0.55,
            0.6,
            1.0
          ],
          "fontsize": 11.0,
          "id": "obj-18",
          "jspainterfile": "oxford-transparent.js",
          "maxclass": "live.toggle",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            "int"
          ],
          "parameter_enable": 1,
          "patching_rect": [
            129.0,
            98.0,
            58.0,
            26.0
          ],
          "presentation": 1,
          "presentation_rect": [
            292.0,
            98.0,
            58.0,
            26.0
          ],
          "saved_attribute_attributes": {
            "activebgoncolor": {
              "expression": ""
            },
            "valueof": {
              "parameter_enum": [
                "Off",
                "On"
              ],
              "parameter_initial": [
                0
              ],
              "parameter_initial_enable": 1,
              "parameter_longname": "Band Split",
              "parameter_mmax": 1,
              "parameter_modmode": 0,
              "parameter_shortname": "Band Split",
              "parameter_type": 2,
              "parameter_unitstyle": 9
            }
          },
          "varname": "split",
          "annotation": "Applies Oxford Inflator to low, mid and high bands separately. Turn it off for full-range processing.",
          "annotation_name": "Band Split"
        }
      },
      {
        "box": {
          "id": "ox-ctl5",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            144.0,
            246.0,
            117.0,
            20.0
          ],
          "text": "prepend control 5",
          "varname": "ctl5"
        }
      },
      {
        "box": {
          "activebgoncolor": [
            0.3,
            0.55,
            0.6,
            1.0
          ],
          "fontsize": 11.0,
          "id": "obj-20",
          "jspainterfile": "oxford-transparent.js",
          "maxclass": "live.toggle",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            "int"
          ],
          "parameter_enable": 1,
          "patching_rect": [
            129.0,
            66.0,
            58.0,
            26.0
          ],
          "presentation": 1,
          "presentation_rect": [
            292.0,
            66.0,
            58.0,
            26.0
          ],
          "saved_attribute_attributes": {
            "activebgoncolor": {
              "expression": ""
            },
            "valueof": {
              "parameter_enum": [
                "Off",
                "On"
              ],
              "parameter_initial": [
                1
              ],
              "parameter_initial_enable": 1,
              "parameter_longname": "Clip 0 dB",
              "parameter_mmax": 1,
              "parameter_modmode": 0,
              "parameter_shortname": "Clip 0 dB",
              "parameter_type": 2,
              "parameter_unitstyle": 9
            }
          },
          "varname": "clip",
          "annotation": "Clips the signal feeding the Oxford Inflator effect at 0 dBFS.",
          "annotation_name": "Clip 0 dB"
        }
      },
      {
        "box": {
          "id": "ox-ctl6",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            273.0,
            246.0,
            117.0,
            20.0
          ],
          "text": "prepend control 6",
          "varname": "ctl6"
        }
      },
      {
        "box": {
          "id": "obj-22",
          "maxclass": "live.toggle",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "parameter_enable": 1,
          "patching_rect": [
            740.0,
            28.0,
            20.0,
            20.0
          ],
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_enum": [
                "Off",
                "On"
              ],
              "parameter_initial": [
                0
              ],
              "parameter_initial_enable": 1,
              "parameter_invisible": 1,
              "parameter_longname": "VST3 Bypass",
              "parameter_mmax": 1,
              "parameter_modmode": 0,
              "parameter_shortname": "VST3 Bypass",
              "parameter_type": 2,
              "parameter_unitstyle": 9
            }
          },
          "varname": "hostBypass"
        }
      },
      {
        "box": {
          "id": "ox-ctl7",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            402.0,
            246.0,
            117.0,
            20.0
          ],
          "text": "prepend control 7",
          "varname": "ctl7"
        }
      },
      {
        "box": {
          "fontsize": 11.0,
          "id": "obj-7",
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
            250.0,
            144.0,
            103.0,
            21.0
          ],
          "presentation": 1,
          "presentation_rect": [
            165.0,
            2.0,
            314.0,
            23.0
          ],
          "text": "Öppna plugin",
          "texton": "Öppna plugin",
          "varname": "editorButton",
          "annotation": "Opens the Oxford Inflator plug-in editor.",
          "annotation_name": "Open plug-in"
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
              "parameter_longname": "Sonnox state",
              "parameter_modmode": 0,
              "parameter_shortname": "Sonnox state",
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
            79.0,
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
          "varname": "preDrive",
          "annotation": "Adjusts the signal level before Oxford Inflator. With Compensate output enabled, the opposite adjustment is applied after the plug-in.",
          "annotation_name": "Pre Gain"
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
            504.0,
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
          "varname": "postOutput",
          "annotation": "Adjusts the signal level after Oxford Inflator, independently of output compensation.",
          "annotation_name": "Post Gain"
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
          "fontsize": 9.0,
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
            102.0,
            128.0,
            16.0,
            15.0
          ],
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_enum": [
                "Off",
                "On"
              ],
              "parameter_initial": [
                0
              ],
              "parameter_initial_enable": 1,
              "parameter_longname": "Drive Link",
              "parameter_mmax": 1,
              "parameter_modmode": 0,
              "parameter_shortname": "Compensate output",
              "parameter_type": 2
            }
          },
          "text": "",
          "texton": "",
          "varname": "driveLink",
          "annotation": "Offsets Pre Gain after the plug-in. For example, +6 dB of Pre Gain adds −6 dB after the plug-in. Post Gain stays independently adjustable.",
          "annotation_name": "Compensate output"
        }
      },
      {
        "box": {
          "id": "compensateOutputLabel",
          "varname": "compensateOutputLabel",
          "maxclass": "jsui",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            59.0,
            136.0,
            106.0,
            16.0
          ],
          "presentation": 1,
          "presentation_rect": [
            57.0,
            145.0,
            106.0,
            16.0
          ],
          "annotation": "Offsets Pre Gain after the plug-in. For example, +6 dB of Pre Gain adds −6 dB after the plug-in. Post Gain stays independently adjustable.",
          "annotation_name": "Compensate output",
          "outlettype": [],
          "filename": "wrapper-compensation-label.js",
          "jsarguments": [
            "Compensate output"
          ]
        }
      },
      {
        "box": {
          "id": "compensationLabel",
          "varname": "compensationLabel",
          "maxclass": "jsui",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            450.0,
            178.0,
            106.0,
            16.0
          ],
          "presentation": 1,
          "presentation_rect": [
            482.0,
            145.0,
            106.0,
            16.0
          ],
          "annotation": "Shows how much gain the compensation adds after the plug-in, in addition to Post Gain. It is the opposite of Pre Gain when enabled and 0 dB when disabled.",
          "annotation_name": "Output compensation",
          "outlettype": [],
          "filename": "wrapper-compensation-label.js",
          "jsarguments": [
            "Output compensation"
          ]
        }
      },
      {
        "box": {
          "id": "compensationReadout",
          "varname": "compensationReadout",
          "maxclass": "jsui",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            450.0,
            196.0,
            62.0,
            16.0
          ],
          "presentation": 1,
          "presentation_rect": [
            482.0,
            128.0,
            106.0,
            16.0
          ],
          "annotation": "Shows how much gain the compensation adds after the plug-in, in addition to Post Gain. It is the opposite of Pre Gain when enabled and 0 dB when disabled.",
          "annotation_name": "Output compensation",
          "outlettype": [],
          "filename": "wrapper-compensation-label.js",
          "jsarguments": [
            "0.0 dB"
          ]
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
          "varname": "inputMeter",
          "annotation": "Shows the input signal's short-term LUFS, RMS and sample peak (dBFS). Click to reset both meters.",
          "annotation_name": "Input meter"
        }
      },
      {
        "box": {
          "background": 1,
          "filename": "oxford-meter-peak.js",
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
            589.0,
            0.0,
            120.0,
            169.0
          ],
          "varname": "outputMeter",
          "annotation": "Shows the output signal's short-term LUFS, RMS and sample peak (dBFS). Click to reset both meters.",
          "annotation_name": "Output meter"
        }
      },
      {
        "box": {
          "fontsize": 9.0,
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
            650.0,
            43.0,
            54.0,
            20.0
          ],
          "text": "Gain match",
          "texton": "Gain match",
          "varname": "match0",
          "annotation": "Adjusts Post Gain so the output matches the input's short-term LUFS.",
          "annotation_name": "Gain match · LUFS"
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
            650.0,
            85.0,
            54.0,
            20.0
          ],
          "text": "Gain match",
          "texton": "Gain match",
          "varname": "match1",
          "annotation": "Adjusts Post Gain so the output matches the input's RMS level.",
          "annotation_name": "Gain match · RMS"
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
            650.0,
            127.0,
            54.0,
            20.0
          ],
          "text": "Gain match",
          "texton": "Gain match",
          "varname": "match2",
          "annotation": "Adjusts Post Gain so the output matches the input's sample peak level.",
          "annotation_name": "Gain match · Peak"
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
          "text": "dialog \"Oxford Inflator · VST3\" @mode 1",
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
          "id": "ox-edit",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            890.0,
            375.0,
            93.0,
            20.0
          ],
          "text": "action",
          "varname": "edit"
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
          "text": "vst~ 2 2 @prefer VST3 @autosave 0 @parameter_enable 1",
          "saved_object_attributes": {
            "parameter_enable": 1
          },
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Private plug-in host",
              "parameter_shortname": "Host",
              "parameter_type": 3,
              "parameter_invisible": 2
            }
          },
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
      }
    ],
    "lines": [
      {
        "patchline": {
          "destination": [
            "ox-ctl1",
            0
          ],
          "source": [
            "obj-10",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-ctl2",
            0
          ],
          "source": [
            "obj-12",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-ctl3",
            0
          ],
          "source": [
            "obj-14",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-ctl4",
            0
          ],
          "source": [
            "obj-16",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-ctl5",
            0
          ],
          "source": [
            "obj-18",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-ctl6",
            0
          ],
          "source": [
            "obj-20",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-ctl7",
            0
          ],
          "source": [
            "obj-22",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-edit",
            0
          ],
          "source": [
            "obj-7",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "ox-ctl0",
            0
          ],
          "source": [
            "obj-8",
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
            "ox-ctl0",
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
            "ox-ctl1",
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
            "ox-ctl2",
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
            "ox-ctl3",
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
            "ox-ctl4",
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
            "ox-ctl5",
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
            "ox-ctl6",
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
            "ox-ctl7",
            0
          ]
        }
      },
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
            "ox-ctrl",
            0
          ],
          "source": [
            "ox-edit",
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
      }
    ],
    "parameters": {
      "obj-10": [
        "Effect",
        "Effect",
        0
      ],
      "obj-12": [
        "Curve",
        "Curve",
        0
      ],
      "obj-14": [
        "Output Gain",
        "Output",
        0
      ],
      "obj-16": [
        "Effect In",
        "Effect In",
        0
      ],
      "obj-18": [
        "Band Split",
        "Band Split",
        0
      ],
      "obj-20": [
        "Clip 0 dB",
        "Clip 0 dB",
        0
      ],
      "obj-22": [
        "VST3 Bypass",
        "VST3 Bypass",
        0
      ],
      "obj-8": [
        "Input Gain",
        "Input",
        0
      ],
      "ox-bankState": [
        "Sonnox state",
        "Sonnox state",
        0
      ],
      "ox-driveLink": [
        "Drive Link",
        "Compensate output",
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
      "parameterbanks": {
        "0": {
          "index": 0,
          "name": "Oxford Inflator",
          "parameters": [
            "Input Gain",
            "Effect",
            "Curve",
            "Output Gain",
            "Effect In",
            "Band Split",
            "Clip 0 dB",
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
    "oscreceiveudpport": 0
  }
}
