# Every update requires an update of these hashes and the version within the control file of each of the 32 ports.
# So it is probably better to have a central location for these hashes and let the ports update via a script
set(QT_MAJOR_MINOR_VER 5.15)
set(QT_PATCH_VER 16)
set(QT_UPDATE_VERSION 0) # Switch to update qt and not build qt. Creates a file cmake/qt_new_hashes.cmake in qt5-base with the new hashes.

set(QT_PORT_LIST base 3d activeqt charts connectivity datavis3d declarative gamepad graphicaleffects imageformats location macextras mqtt multimedia networkauth
                 purchasing quickcontrols quickcontrols2 remoteobjects script scxml sensors serialport speech svg tools virtualkeyboard webchannel websockets
                 webview winextras xmlpatterns doc x11extras androidextras translations serialbus webengine webglplugin wayland)

set(QT_HASH_qt5-3d               74884e87f9dc5c38eecc8685c83fc17b76f449cadff9e4c4fcef1f9795a175dbc4fecfa982d03b5dca591ddb8fbc18533bc178fd32685916b50ef8b7a8f9c83f)
set(QT_HASH_qt5-activeqt         573c747e1f2bb9ac0cbe99b8ed06e387032c5c77a00498080c2067b92a66c41c699f88bab91fc2460c9c0ad126fd87aeac06ca222b568f308cbc762981bea4fd)
set(QT_HASH_qt5-androidextras    0a875cf6da0cc9ba54da8dbafb84950a5f78a06502d06be6f0a5ee24661faf52d05030a94e45fe056315322fb1b2bafcd7b9960aa263aa9951d598a219873c09)
set(QT_HASH_qt5-base             5b44d7fe7bdb806a079eb2e55d28ae8251328b9dffe8488198fb24edec8394e04495937774ea880598d70d7f11bc89ca2cb48f0e28a555fad5344663630f3f40)
set(QT_HASH_qt5-charts           835f728e63f0bd65b84e015177527afc53c265a488b79164c61f4d8b7f707c666fe8f6f5681343fe3750fe0c9bd0c4245324bf20282de64a9f45945ffa163575)
set(QT_HASH_qt5-connectivity     37605834aa683ad679b25319551fe3fc91190f8bf3adff2df66cc66e674b0e73b83395aedcec3428ab0f675dda92222c2e2a6f09119c857de6aa072a249cb8b6)
set(QT_HASH_qt5-datavis3d        8bedb4cbd78f272ffb201382d9cefddb7ac249fb82d91273fc455d1292d6450506f02177c035eec7acf1c30e3897fa30e734ccc189b4d4e730c63016af15b0c0)
set(QT_HASH_qt5-declarative      8eaa513df125c3ed89abd300365be9b54f8cce86da9864ae58b701f1f6471eb883e384a6769c0631c98d335f186f6ccb8775ddf03794f47d259b9e217f20df0e)
set(QT_HASH_qt5-doc              c178ba84d85ec1460334963833e82f553a0273fd0e6ac99b273715e564d0f1ce77359488dbe5fbd1c7ab74e81ab35740f43e7741d1943cdadb80a6367b2fb48d)
set(QT_HASH_qt5-gamepad          18ccdf20f03d97198d847628ce8c8ed7aee343039bbd74fb4ec4bb7f5ecc236b878bf4156210cc63f8f2ca60543e110fc7088b2eee5249b28e05998d1beadc52)
set(QT_HASH_qt5-graphicaleffects 05a30ed641c8d1d674fe4e1c873d1f23407b3ddbc6d0c21e6b0e96af763099fe54c3499970b0225b5eeef71f9a9b64f7f96d1de60a7386e393b2d27864e0fb6c)
set(QT_HASH_qt5-imageformats     6605c9647ea2b89ea48dc530a375df5a75da9a83015f8c0ea5310360996385e67daf32d201365aef7b22d4b1caa22e2d838e3f993e3218d1212038edc33469a1)
set(QT_HASH_qt5-location         dab281259497076924a0b8ec31673bec8e4291512e97cecaec6824532652c88546b86e982b9e9646ac492dcae59c75e698fc108c4020f16ca62c7e6778b9b590)
set(QT_HASH_qt5-macextras        6dffc96417842f5a9fc75490c3ee4cfccdd6f5cd6240fef54ec0b1ce9ee59eba3582f8c111a78a58030738da3602de584c7a839196b0f2148ca6970304667f7a)
set(QT_HASH_qt5-mqtt             0)
set(QT_HASH_qt5-multimedia       69ff2463755974d95be8b112ea97df110c4c4b7f3843cc1c1d5d571d93cd1543d8ee74e0b002ce5b1148bd5a121b8fc1fa64f5efe137e817449584b1964f69d4)
set(QT_HASH_qt5-networkauth      676531c75c43c85e5f1f44d1c825668610ac86e30e7ed40e179d3ca33c592a43a0064cbe89e9a8a257367fc1972355cf43e9230cac06bf3ed8d4871c5b784bbb)
set(QT_HASH_qt5-purchasing       c0286d9ad5ad2cb0f9fd9953cdf62ddf6062b03cd0a30fe50c69294fd0785baf33d038b1b4c4cdead520c0651d00ee68137e91622433c98fdd8d7eb385cc6b79)
set(QT_HASH_qt5-quickcontrols    343a6883c2c26b2768f3c2c170a0713a426a03ccf13c74309e15443ea83aff20d9919e3eecaa92dc060839579d31d012cff7feeaa7d951654d8d3446db9bf5c1)
set(QT_HASH_qt5-quickcontrols2   66ea0d80c372304a13961f1755234504293f8bcce9500cb430ef0a25798cb80e286d212b544e944ade986b6484526ed9b5559724000ff3d726d983a24ade7ed3)
set(QT_HASH_qt5-remoteobjects    ab862525bd1a57c451c8827e7a60a7239f7206c564be9979d2bc2095418de536fcf269b86643f8747097e52a5aecf98196b11ccbaffcca6aa558be0fc3cf9617)
set(QT_HASH_qt5-script           3b1b1761c14a0c0eaa272e7d9423868c76405a79a20ee55313fdf9ee0560b9efe80d2b59d67c58a63dd76288dc8d47903e446b4b9856ca01bca2af22030abe4c)
set(QT_HASH_qt5-scxml            a24a1e1ad9e02b27a72eaf486b66a3db2c940e9caa9021823e7d78096afab5925ed4e675ff6aedc5c537070e408932bd432e4c9175341e13094239dee6ddc457)
set(QT_HASH_qt5-sensors          bc774ac841018d148bb2ca2329685dd7e2cb565c3089e192fdf6be5538dcfba8e30fe7e2a507604234db341dc84a5ae9535a5b12ef43254952ef36fa0d418eba)
set(QT_HASH_qt5-serialbus        3ec602d2b88165b15879577def72f6012b9213f5994cea066eb18e64a1627c77a7d2597ddef9bd12bca80850fea48c2d1494e277a7cc86654615649cbc1291af)
set(QT_HASH_qt5-serialport       c0d0a41d634a6a4221abe725249d9abaeeb47f0351d81d8ba1125783230f8b3f7a5286fc6b6e40a7e810ac2b63bcb6e1c64b14b9b3c75285047f50769ac7ccbb)
set(QT_HASH_qt5-speech           4a8ca1ac8d410ba627eb8db6212e6aa208fa89079f18bd65cbc6e0078d9979feb439bf4c9c0e6c6e4239e0bd60adf7633c7e5a60153b1d18a87596137d8686ed)
set(QT_HASH_qt5-svg              907aa03ef93c3a997f6e248fd5eeba17bc30a2cdcefa7d57c9bb096ed562eb850558b0adb741eaa0277250b67e079ec6970a0a370d5afe491594ee816fb412b7)
set(QT_HASH_qt5-tools            ce1fdeb8499edb52c343638dabb8f5b42f4c9260097a6ff60e3c5cc4d1525199dc78cb65924593d029bd85c8bdd379642a72e1618f040abf4f9f4693a374730a)
set(QT_HASH_qt5-translations     330be9f6c2937416392dee3bcd68ea2fd0842e7ae1c7c93499ccdf03f3736b1b1b7e99d8e081aeb1970fec3718f7cb214bcf7bb303997b29c656808a5e04d327)
set(QT_HASH_qt5-virtualkeyboard  91fbe22096877da697a9975e9bec5c6eab3646cd8cfb514ff00d55c2f108d121aeeee0eee8805591060c53c5f984475337cf9a598a1ce27a9de8eed5455015b6)
set(QT_HASH_qt5-wayland          cd422203c8d84d4f48971790088b70cab2cba143981c275495ef2739850bec1918d74b7200df6e3e1beeb213136955786d0571d3a8c0ae8f6e6c50a55b0568d1)
set(QT_HASH_qt5-webchannel       34f4713afa36e3c1284b5e21a9f28a27a2a0bd965a1b0300233036785fe3898e36be5b981daa48bc3baedf1fdc780578902817527c159fa8896fc0d098079065)
set(QT_HASH_qt5-webengine        2f51cae5bf255fa353e7396cde8fd96fc72885052b339d042a069edd24f7cec0ddfc4e098a4e1713fd5ca96bcb4f33f114e8ba4e41bcb36f17939b686ee5b78f)
set(QT_HASH_qt5-webglplugin      478429fc9d95842bcb93727c1677d121d3b12dd5094f678b111e31139b68f0197d3d1a88b7ff36b21f932ebdc0e62a069f3a8755a4341f09dbcfd7051346709d)
set(QT_HASH_qt5-websockets       7e4a3af0ebdbb5b639fdfeddb34e802cba51c002b1549a328ec796472bd0db32bbf3aa755b249e8174162932a80bfe240985dbc0269aea091159b4c1a6f8b572)
set(QT_HASH_qt5-webview          b8a95ee5433a6492cbfac386df3e67a75d7a2f18c55086a910cd0bd955ca8f19ce400b2e7337fb68ee3ba4aabdde66d8b280b9686f12faaf6eb2ca604996e07c)
set(QT_HASH_qt5-winextras        e3bdfaf14762dde554227ed1641292c4b92878d9f3254895e49b979b7f769564307357e4e0ac21cc53133963075654e2477a3748548ec4a894fd1de00089f463)
set(QT_HASH_qt5-x11extras        2a46795c49da280e2d8f1c4978d7969e2f64f540e54489836d8ef4f966244de80826a0ea9b35e51150122fe69e2c844d26974f536623bbf147e7f104ddbb65ce)
set(QT_HASH_qt5-xmlpatterns      a13c804cec025f42c0e755d6dc1e213d6f474cd9d2051c6ed2450f159b45f376194a26d6f4c1dfa27ee7f541cfbeead8e8f09da6036672e9b425d6990b97b6b5)

if(QT_UPDATE_VERSION)
    message(STATUS "Running Qt in automatic version port update mode!")
    set(_VCPKG_INTERNAL_NO_HASH_CHECK 1)
    if("${PORT}" MATCHES "qt5-base")
        function(update_qt_version_in_manifest _port_name)
            set(_current_control "${VCPKG_ROOT_DIR}/ports/${_port_name}/vcpkg.json")
            file(READ ${_current_control} _control_contents)
            #message(STATUS "Before: \n${_control_contents}")
            string(REGEX REPLACE "\"version.*\": \"[0-9]+\.[0-9]+\.[0-9]+\",\n" "\"version\": \"${QT_MAJOR_MINOR_VER}.${QT_PATCH_VER}\",\n" _control_contents "${_control_contents}")
            string(REGEX REPLACE "\n  \"port-version\": [0-9]+," "" _control_contents "${_control_contents}")
            #message(STATUS "After: \n${_control_contents}")
            file(WRITE ${_current_control} "${_control_contents}")
            configure_file("${_current_control}" "${_current_control}" @ONLY NEWLINE_STYLE LF)
        endfunction()

        update_qt_version_in_manifest("qt5")
        foreach(_current_qt_port_basename ${QT_PORT_LIST})
            update_qt_version_in_manifest("qt5-${_current_qt_port_basename}")
        endforeach()
    endif()
endif()
