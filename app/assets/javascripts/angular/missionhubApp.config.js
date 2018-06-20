angular
    .module('missionhubApp')
    .config(function(
        envServiceProvider,
        ngMdIconServiceProvider,
        I18n,
        $qProvider,
    ) {
        envServiceProvider.config({
            domains: {
                development: ['localhost', 'missionhub.local'],
                staging: ['stage.missionhub.com'],
                production: ['missionhub.com', 'www.missionhub.com'],
            },
            vars: {
                development: {
                    apiUrl: 'https://api-stage.missionhub.com/apis/v4',
                },
                staging: {
                    apiUrl: 'https://api-stage.missionhub.com/apis/v4',
                },
                production: {
                    apiUrl: 'https://api.missionhub.com/apis/v4',
                },
            },
        });

        // run the environment check, so the comprobation is made
        // before controllers and services are built
        envServiceProvider.check();

        /* eslint-disable max-len */
        ngMdIconServiceProvider.addShapes({
            dashboard:
                '<g transform="translate(-180, -24)">' +
                '<path d="M203.78075,35.46975 L192.53075,24.21975 C192.23775,23.92675 191.76275,23.92675 191.46975,24.21975 L180.21975,35.46975 C179.92675,35.76275 179.92675,36.23775 180.21975,36.53075 C180.51275,36.82375 180.98775,36.82375 181.28075,36.53075 L182.25075,35.56075 L182.25075,47.24975 C182.25075,47.66375 182.58675,47.99975 183.00075,47.99975 L189.00075,47.99975 C189.41475,47.99975 189.75075,47.66375 189.75075,47.24975 L189.75075,39.74975 L194.25075,39.74975 L194.25075,47.24975 C194.25075,47.66375 194.58675,47.99975 195.00075,47.99975 L201.00075,47.99975 C201.41475,47.99975 201.75075,47.66375 201.75075,47.24975 L201.75075,35.56075 L202.71975,36.53075 C202.86675,36.67675 203.05775,36.74975 203.25075,36.74975 C203.44275,36.74975 203.63375,36.67675 203.78075,36.53075 C204.07375,36.23775 204.07375,35.76275 203.78075,35.46975 L203.78075,35.46975 Z M200.25075,34.06075 L200.25075,46.49975 L195.75075,46.49975 L195.75075,38.99975 C195.75075,38.58575 195.41475,38.24975 195.00075,38.24975 L189.00075,38.24975 C188.58675,38.24975 188.25075,38.58575 188.25075,38.99975 L188.25075,46.49975 L183.75075,46.49975 L183.75075,34.06075 L192.00075,25.81075 L200.25075,34.06075 Z" id="Fill-1"></path>' +
                '</g>',
            discipleship:
                '<g transform="translate(-830, -18)">' +
                '<path d="M851.818281,41.1818145 L851.818281,33.3610516 C851.818281,33.1952327 851.768099,33.0337774 851.67428,32.8963223 C850.387002,31.0275865 848.550993,29.6683076 846.473893,28.9483043 C848.051355,27.8661176 849.090996,26.0530184 849.090996,23.9999182 C849.090996,20.6911759 846.39862,17.9998909 843.090969,17.9998909 C840.724776,17.9998909 838.693494,19.3886245 837.717126,21.3839063 C834.808749,21.1013596 832.360738,23.3846427 832.360738,26.236292 C832.360738,28.0352093 833.343652,29.5941254 834.790204,30.449402 C832.932377,31.0134046 831.284006,32.1741372 830.147273,33.8061446 C830.051273,33.9435997 830,34.1061459 830,34.2741467 L830,41.1818145 C830,41.6334529 830.366547,42 830.818186,42 C831.269824,42 831.636371,41.6334529 831.636371,41.1818145 L831.636371,34.5381479 C832.524375,33.3545062 833.766926,32.530866 835.144751,32.0825004 C834.923295,32.3443197 834.705112,32.6105028 834.507657,32.8963223 C834.413838,33.0337774 834.363656,33.1952327 834.363656,33.3610516 L834.363656,41.1818145 C834.363656,41.6334529 834.730203,42 835.181842,42 C835.63348,42 836.000027,41.6334529 836.000027,41.1818145 L836.000027,33.6217801 C837.659308,31.3483152 840.292774,29.9999455 843.090969,29.9999455 C845.889163,29.9999455 848.52263,31.3483152 850.18191,33.6217801 L850.18191,41.1818145 C850.18191,41.6334529 850.548457,42 851.000095,42 C851.451734,42 851.818281,41.6334529 851.818281,41.1818145 M839.411316,28.7039396 C838.822222,29.2144873 838.067309,29.5090341 837.269851,29.5090341 C835.464388,29.5090341 833.997109,28.0406638 833.997109,26.236292 C833.997109,24.4570112 835.425116,23.0115501 837.194578,22.9711862 C837.13676,23.3071878 837.090941,23.6475529 837.090941,23.9999182 C837.090941,25.9155633 838.009491,27.6042982 839.411316,28.7039396 M843.090969,28.3635744 C840.684412,28.3635744 838.727312,26.4064746 838.727312,23.9999182 C838.727312,21.5933618 840.684412,19.636262 843.090969,19.636262 C845.497525,19.636262 847.454625,21.5933618 847.454625,23.9999182 C847.454625,26.4064746 845.497525,28.3635744 843.090969,28.3635744"></path>' +
                '</g>',
            assignedPeople:
                '<g transform="translate(-535, -19)">' +
                '<path d="M559,40.2499 L559,33.9179 C559,33.7639 558.953,33.6149 558.865,33.4889 C557.823,31.9929 556.312,30.9299 554.609,30.4119 C555.936,29.6279 556.837,28.1989 556.837,26.5499 C556.837,23.9349 554.601,21.8399 551.926,22.1019 C551.031,20.2729 549.169,18.9999 547,18.9999 C544.831,18.9999 542.969,20.2729 542.074,22.1019 C539.408,21.8429 537.164,23.9359 537.164,26.5499 C537.164,28.1989 538.065,29.6279 539.391,30.4119 C537.688,30.9289 536.177,31.9929 535.135,33.4889 C535.047,33.6149 535,33.7639 535,33.9179 L535,40.2499 C535,40.6639 535.336,40.9999 535.75,40.9999 C536.164,40.9999 536.5,40.6639 536.5,40.2499 L536.5,34.1599 C537.314,33.0749 538.453,32.3199 539.716,31.9089 C539.513,32.1489 539.313,32.3929 539.132,32.6549 C539.046,32.7809 539,32.9289 539,33.0809 L539,40.2499 C539,40.6639 539.336,40.9999 539.75,40.9999 C540.164,40.9999 540.5,40.6639 540.5,40.2499 L540.5,33.3199 C542.021,31.2359 544.435,29.9999 547,29.9999 C549.565,29.9999 551.979,31.2359 553.5,33.3199 L553.5,40.2499 C553.5,40.6639 553.836,40.9999 554.25,40.9999 C554.664,40.9999 555,40.6639 555,40.2499 L555,33.0809 C555,32.9289 554.954,32.7809 554.868,32.6549 C554.687,32.3929 554.487,32.1489 554.284,31.9089 C555.548,32.3199 556.686,33.0749 557.5,34.1599 L557.5,40.2499 C557.5,40.6639 557.836,40.9999 558.25,40.9999 C558.664,40.9999 559,40.6639 559,40.2499 M543.627,28.8119 C543.087,29.2799 542.395,29.5499 541.664,29.5499 C540.009,29.5499 538.664,28.2039 538.664,26.5499 C538.664,24.9189 539.973,23.5939 541.595,23.5569 C541.542,23.8649 541.5,24.1769 541.5,24.4999 C541.5,26.2559 542.342,27.8039 543.627,28.8119 M551,24.4999 C551,26.7059 549.206,28.4999 547,28.4999 C544.794,28.4999 543,26.7059 543,24.4999 C543,22.2939 544.794,20.4999 547,20.4999 C549.206,20.4999 551,22.2939 551,24.4999 M552.337,29.5499 C551.605,29.5499 550.913,29.2799 550.373,28.8109 C551.658,27.8039 552.5,26.2559 552.5,24.4999 C552.5,24.1769 552.458,23.8649 552.405,23.5569 C554.027,23.5939 555.337,24.9189 555.337,26.5499 C555.337,28.2039 553.991,29.5499 552.337,29.5499"></path>' +
                '</g>',
            uncontactedPerson:
                '<g transform="translate(-584, -19)">' +
                '<path d="M608,34.75 C608,31.304 605.196,28.5 601.75,28.5 C600.076,28.5 598.562,29.17 597.439,30.245 C596.708,29.731 595.917,29.337 595.091,29.045 C596.543,28.054 597.5,26.387 597.5,24.5 C597.5,21.467 595.032,19 592,19 C588.967,19 586.5,21.467 586.5,24.5 C586.5,26.382 587.453,28.044 588.899,29.036 C586.995,29.696 585.312,30.942 584.132,32.655 C584.046,32.78 584,32.929 584,33.081 L584,40.25 C584,40.664 584.336,41 584.75,41 C585.164,41 585.5,40.664 585.5,40.25 L585.5,33.32 C587.022,31.236 589.435,30 592,30 C593.629,30 595.16,30.501 596.488,31.408 C595.87,32.376 595.5,33.518 595.5,34.75 C595.5,38.196 598.304,41 601.75,41 C605.196,41 608,38.196 608,34.75 M592,28.5 C589.795,28.5 588,26.706 588,24.5 C588,22.295 589.795,20.5 592,20.5 C594.206,20.5 596,22.295 596,24.5 C596,26.706 594.206,28.5 592,28.5 M606.5,34.75 C606.5,37.369 604.369,39.5 601.75,39.5 C599.131,39.5 597,37.369 597,34.75 C597,32.131 599.131,30 601.75,30 C604.369,30 606.5,32.131 606.5,34.75 M602.75,37 C602.75,36.448 602.302,36 601.75,36 C601.198,36 600.75,36.448 600.75,37 C600.75,37.552 601.198,38 601.75,38 C602.302,38 602.75,37.552 602.75,37 M602.5,34.75 L602.5,32.25 C602.5,31.836 602.164,31.5 601.75,31.5 C601.336,31.5 601,31.836 601,32.25 L601,34.75 C601,35.164 601.336,35.5 601.75,35.5 C602.164,35.5 602.5,35.164 602.5,34.75"></path>' +
                '</g>',
            holySpirit:
                '<g transform="translate(-981.000000, -217.000000)">' +
                '<path d="M1002.61452,237.519118 C1002.19602,238.033618 1001.08453,239.400116 1000.38328,239.400116 C1000.32403,239.400116 1000.26778,239.390366 1000.21078,239.370116 C999.612277,239.162366 998.889278,237.912118 998.567529,237.092369 C998.476779,236.859869 998.289279,236.686619 998.06053,236.62437 C997.99903,236.60787 997.93678,236.59962 997.87528,236.59962 C997.70578,236.59962 997.53928,236.660369 997.405031,236.775869 C997.388531,236.790119 995.758033,238.164117 993.380536,238.164117 C992.251788,238.164117 991.13204,237.849868 990.050541,237.230369 C988.254294,236.19987 987.420295,234.263373 986.684546,232.554875 C985.876047,230.677628 985.040548,228.736631 982.996801,228.736631 C982.903052,228.736631 982.807802,228.740381 982.711802,228.748631 C983.101801,227.611633 983.98755,227.092633 985.476298,227.092633 C987.139045,227.092633 989.089793,227.785632 990.137541,228.158382 C990.329541,228.227382 990.541041,228.209382 990.72029,228.109632 C990.90029,228.009882 991.03529,227.836632 991.09379,227.629633 C991.14854,227.433883 992.068038,224.310887 994.563285,222.24164 C994.630785,222.20489 994.696034,222.159141 994.753034,222.099141 C994.760534,222.090141 994.766534,222.079641 994.774034,222.070641 C996.002533,221.117392 997.58953,220.425893 999.616027,220.425893 C1000.16203,220.425893 1000.72753,220.476893 1001.31177,220.577393 C1000.41253,221.544141 999.340028,223.291639 998.645529,226.414634 C997.99678,229.33213 995.869033,231.608377 995.848783,231.630127 C995.578783,231.913626 995.549533,232.365876 995.779783,232.685375 C995.846533,232.779125 997.46053,234.973622 1000.93903,234.973622 C1001.71152,234.973622 1002.52602,234.863372 1003.35927,234.646622 C1003.39302,234.637622 1003.41852,234.633122 1003.44252,234.632372 C1003.61802,234.980372 1003.43952,236.50587 1002.61452,237.519118 M992.740037,219.324145 C992.819537,219.996144 992.968787,220.757393 993.238787,221.370142 C991.390789,223.098139 990.368541,225.266386 989.926041,226.401134 C989.630542,226.299885 989.301292,226.192635 988.950293,226.087635 C989.167793,224.849387 989.962791,221.811891 992.740037,219.324145 M1004.80227,233.965623 C1004.48652,233.226874 1003.80252,232.882625 1003.00302,233.091875 C1002.28602,233.278624 1001.59152,233.373874 1000.93903,233.373874 C999.131528,233.373874 997.98928,232.660625 997.415531,232.168626 C998.175279,231.219127 999.561277,229.23013 1000.10428,226.784384 C1001.21503,221.791641 1003.33002,220.970392 1003.33602,220.967392 C1003.65627,220.867642 1003.87527,220.554143 1003.87527,220.198643 C1003.87452,219.843894 1003.65477,219.531144 1003.33527,219.431394 C1002.04302,219.030145 1000.79128,218.826145 999.616027,218.826145 C997.52578,218.826145 995.831533,219.462144 994.473285,220.381643 C994.269285,219.712644 994.150785,218.669396 994.149285,217.799397 C994.149285,217.504647 993.997035,217.233148 993.753286,217.094398 C993.509536,216.955648 993.213287,216.970648 992.983037,217.134148 C988.924793,220.020144 987.793795,224.010138 987.487045,225.720135 C986.824796,225.585886 986.139297,225.492136 985.476298,225.492136 C982.804802,225.492136 981.216304,226.998134 981.002554,229.73338 C980.981554,230.004129 981.091054,230.268129 981.293554,230.434629 C981.495304,230.599628 981.763803,230.643878 982.003053,230.552378 C982.378802,230.409129 982.713302,230.336379 982.996801,230.336379 C984.02805,230.336379 984.527549,231.378877 985.321798,233.222374 C986.113797,235.063622 987.101546,237.354868 989.340292,238.639617 C990.64154,239.385866 992.001288,239.764615 993.380536,239.764615 C995.246534,239.764615 996.731532,239.073116 997.57603,238.561617 C998.00803,239.388866 998.764029,240.549864 999.745777,240.891113 C999.952777,240.963113 1000.16728,240.999863 1000.38328,240.999863 C1001.53377,240.999863 1002.56052,240.027865 1003.74777,238.567617 C1004.68527,237.415618 1005.34902,235.242122 1004.80227,233.965623" transform="translate(993.000000, 228.999932) scale(-1, 1) translate(-993.000000, -228.999932)"></path>' +
                '</g>',
            personalDecision:
                '<g transform="translate(-731, -20)">' +
                '<path d="M743.046,42.0002505 C742.879,42.0002505 742.711,41.9442505 742.573,41.8322505 L733.156,34.1732505 C731.746,32.7692505 731,30.9692505 731,29.0552505 C731,27.1412505 731.746,25.3422505 733.099,23.9892505 C735.663,21.4252505 740.124,21.3512505 743,23.7012505 C745.875,21.3522505 750.337,21.4262505 752.9,23.9892505 C754.254,25.3422505 755,27.1412505 755,29.0552505 C755,30.9692505 754.254,32.7692505 752.9,34.1222505 L743.522,41.8302505 C743.383,41.9432505 743.214,42.0002505 743.046,42.0002505 M738.131,23.4872505 C736.656,23.4872505 735.206,24.0072505 734.159,25.0532505 C733.089,26.1222505 732.5,27.5442505 732.5,29.0552505 C732.5,30.5672505 733.089,31.9892505 734.159,33.0572505 L743.044,40.2782505 L751.896,33.0082505 C752.911,31.9892505 753.5,30.5672505 753.5,29.0552505 C753.5,27.5442505 752.911,26.1222505 751.842,25.0532505 C749.676,22.8902505 745.793,22.9812505 743.53,25.2452505 C743.237,25.5372505 742.763,25.5372505 742.47,25.2452505 C741.302,24.0772505 739.703,23.4872505 738.131,23.4872505 M743,36.6742505 C742.586,36.6742505 742.25,36.3372505 742.25,35.9222505 L742.25,31.6632505 L740,31.6632505 C739.586,31.6632505 739.25,31.3262505 739.25,30.9112505 C739.25,30.4962505 739.586,30.1592505 740,30.1592505 L742.25,30.1592505 L742.25,27.9042505 C742.25,27.4892505 742.586,27.1532505 743,27.1532505 C743.414,27.1532505 743.75,27.4892505 743.75,27.9042505 L743.75,30.1592505 L746,30.1592505 C746.414,30.1592505 746.75,30.4962505 746.75,30.9112505 C746.75,31.3262505 746.414,31.6632505 746,31.6632505 L743.75,31.6632505 L743.75,35.9222505 C743.75,36.3372505 743.414,36.6742505 743,36.6742505"></path>' +
                '</g>',
            evangelism:
                '<g transform="translate(-883, -218)">' +
                '<path d="M905.264074,236.113431 C904.231439,235.355208 903.136816,234.714158 901.994946,234.191793 L901.994946,229.835225 L903.695845,229.835225 C904.164915,229.835225 904.546295,229.454223 904.546295,228.984775 C904.546295,228.514949 904.164915,228.134326 903.695845,228.134326 L901.994946,228.134326 L901.994946,226.008202 C901.994946,225.538376 901.613567,225.157753 901.144497,225.157753 C900.674293,225.157753 900.294048,225.538376 900.294048,226.008202 L900.294048,228.134326 L898.593149,228.134326 C898.122945,228.134326 897.742699,228.514949 897.742699,228.984775 C897.742699,229.454223 898.122945,229.835225 898.593149,229.835225 L900.294048,229.835225 L900.294048,233.515214 C898.742072,232.985289 897.120548,232.665898 895.458959,232.565734 L895.080982,232.565734 L895.080982,225.913708 L897.356784,225.913708 C897.773693,225.913708 898.112739,225.57504 898.112739,225.157753 C898.112739,224.740088 897.773693,224.401798 897.356784,224.401798 L895.080982,224.401798 L895.080982,221.755955 C895.080982,221.33829 894.741936,221 894.325026,221 C893.906983,221 893.569071,221.33829 893.569071,221.755955 L893.569071,224.401798 L891.309144,224.401798 C890.891101,224.401798 890.553189,224.740088 890.553189,225.157753 C890.553189,225.57504 890.891101,225.913708 891.309144,225.913708 L893.569071,225.913708 L893.569071,232.565734 L893.191094,232.565734 C891.540844,232.665142 889.929904,232.980753 888.387756,233.504252 L888.387756,229.835225 L890.088654,229.835225 C890.557725,229.835225 890.939104,229.454223 890.939104,228.984775 C890.939104,228.514949 890.557725,228.134326 890.088654,228.134326 L888.387756,228.134326 L888.387756,226.008202 C888.387756,225.538376 888.006376,225.157753 887.537306,225.157753 C887.067102,225.157753 886.686857,225.538376 886.686857,226.008202 L886.686857,228.134326 L884.985958,228.134326 C884.515754,228.134326 884.135508,228.514949 884.135508,228.984775 C884.135508,229.454223 884.515754,229.835225 884.985958,229.835225 L886.686857,229.835225 L886.686857,234.177808 C885.533647,234.703197 884.427685,235.348405 883.385601,236.113431 C882.964912,236.421861 882.874575,237.013774 883.183383,237.434085 C883.368214,237.686196 883.655099,237.82 883.945764,237.82 C884.139666,237.82 884.335837,237.760279 884.504037,237.636303 C887.371752,235.530968 890.767502,234.418202 894.325026,234.418202 C897.882551,234.418202 901.278301,235.530968 904.145638,237.636303 C904.565193,237.945866 905.157484,237.854396 905.466292,237.434085 C905.775478,237.013774 905.684763,236.421861 905.264074,236.113431"></path>' +
                '</g>',
            survey:
                '<g transform="translate(-9, -11)">' +
                '<path d="M30.5000771,34.2499969 L30.5000771,13.9999125 C30.5000771,13.5859108 30.1640757,13.2499094 29.750074,13.2499094 L26.5000604,13.2499094 L26.5000604,11.7499031 C26.5000604,11.3359014 26.164059,10.9999 25.7500573,10.9999 L16.7500198,10.9999 C16.3360181,10.9999 16.0000167,11.3359014 16.0000167,11.7499031 L16.0000167,13.2499094 L12.7500031,13.2499094 C12.3360014,13.2499094 12,13.5859108 12,13.9999125 L12,34.2499969 C12,34.6639986 12.3360014,35 12.7500031,35 L29.750074,35 C30.1640757,35 30.5000771,34.6639986 30.5000771,34.2499969 L30.5000771,34.2499969 Z M25.0000542,13.9999125 L25.0000542,15.4999187 L17.5000229,15.4999187 L17.5000229,13.9999125 L17.5000229,12.4999062 L25.0000542,12.4999062 L25.0000542,13.9999125 Z M29.0000708,33.4999937 L13.5000063,33.4999937 L13.5000063,14.7499156 L16.0000167,14.7499156 L16.0000167,16.2499219 C16.0000167,16.6639236 16.3360181,16.999925 16.7500198,16.999925 L25.7500573,16.999925 C26.164059,16.999925 26.5000604,16.6639236 26.5000604,16.2499219 L26.5000604,14.7499156 L29.0000708,14.7499156 L29.0000708,33.4999937 Z M16.0000167,19.9999375 C16.0000167,20.5529398 16.4480185,20.9999417 17.0000208,20.9999417 C17.5520231,20.9999417 18.000025,20.5529398 18.000025,19.9999375 C18.000025,19.4469352 17.5520231,18.9999333 17.0000208,18.9999333 C16.4480185,18.9999333 16.0000167,19.4469352 16.0000167,19.9999375 L16.0000167,19.9999375 Z M16.0000167,22.99995 C16.0000167,23.5529523 16.4480185,23.9999542 17.0000208,23.9999542 C17.5520231,23.9999542 18.000025,23.5529523 18.000025,22.99995 C18.000025,22.4469477 17.5520231,21.9999458 17.0000208,21.9999458 C16.4480185,21.9999458 16.0000167,22.4469477 16.0000167,22.99995 L16.0000167,22.99995 Z M16.0000167,25.9999625 C16.0000167,26.5529648 16.4480185,26.9999667 17.0000208,26.9999667 C17.5520231,26.9999667 18.000025,26.5529648 18.000025,25.9999625 C18.000025,25.4469602 17.5520231,24.9999583 17.0000208,24.9999583 C16.4480185,24.9999583 16.0000167,25.4469602 16.0000167,25.9999625 L16.0000167,25.9999625 Z M19.0000292,19.9999375 C19.0000292,20.4139392 19.3360306,20.7499406 19.7500323,20.7499406 L25.7500573,20.7499406 C26.164059,20.7499406 26.5000604,20.4139392 26.5000604,19.9999375 C26.5000604,19.5859358 26.164059,19.2499344 25.7500573,19.2499344 L19.7500323,19.2499344 C19.3360306,19.2499344 19.0000292,19.5859358 19.0000292,19.9999375 L19.0000292,19.9999375 Z M19.0000292,22.99995 C19.0000292,23.4139517 19.3360306,23.7499531 19.7500323,23.7499531 L25.7500573,23.7499531 C26.164059,23.7499531 26.5000604,23.4139517 26.5000604,22.99995 C26.5000604,22.5859483 26.164059,22.2499469 25.7500573,22.2499469 L19.7500323,22.2499469 C19.3360306,22.2499469 19.0000292,22.5859483 19.0000292,22.99995 L19.0000292,22.99995 Z M19.0000292,25.9999625 C19.0000292,26.4139642 19.3360306,26.7499656 19.7500323,26.7499656 L25.7500573,26.7499656 C26.164059,26.7499656 26.5000604,26.4139642 26.5000604,25.9999625 C26.5000604,25.5859608 26.164059,25.2499594 25.7500573,25.2499594 L19.7500323,25.2499594 C19.3360306,25.2499594 19.0000292,25.5859608 19.0000292,25.9999625 L19.0000292,25.9999625 Z"></path>' +
                '</g>',
            addPerson:
                '<g transform="translate(-1030, -443)">' +
                '<path d="M1054,458.75 C1054,455.304 1051.196,452.5 1047.75,452.5 C1046.076,452.5 1044.562,453.17 1043.439,454.245 C1042.708,453.731 1041.917,453.337 1041.091,453.045 C1042.543,452.054 1043.5,450.387 1043.5,448.5 C1043.5,445.467 1041.032,443 1038,443 C1034.967,443 1032.5,445.467 1032.5,448.5 C1032.5,450.382 1033.453,452.044 1034.899,453.036 C1032.995,453.696 1031.312,454.942 1030.132,456.655 C1030.046,456.78 1030,456.929 1030,457.081 L1030,464.25 C1030,464.664 1030.336,465 1030.75,465 C1031.164,465 1031.5,464.664 1031.5,464.25 L1031.5,457.32 C1033.022,455.236 1035.435,454 1038,454 C1039.629,454 1041.16,454.501 1042.488,455.408 C1041.87,456.376 1041.5,457.518 1041.5,458.75 C1041.5,462.196 1044.304,465 1047.75,465 C1051.196,465 1054,462.196 1054,458.75 M1038,452.5 C1035.795,452.5 1034,450.706 1034,448.5 C1034,446.295 1035.795,444.5 1038,444.5 C1040.206,444.5 1042,446.295 1042,448.5 C1042,450.706 1040.206,452.5 1038,452.5 M1052.5,458.75 C1052.5,461.369 1050.369,463.5 1047.75,463.5 C1045.131,463.5 1043,461.369 1043,458.75 C1043,456.131 1045.131,454 1047.75,454 C1050.369,454 1052.5,456.131 1052.5,458.75 M1051,458.75 C1051,458.336 1050.664,458 1050.25,458 L1048.5,458 L1048.5,456.25 C1048.5,455.836 1048.164,455.5 1047.75,455.5 C1047.336,455.5 1047,455.836 1047,456.25 L1047,458 L1045.25,458 C1044.836,458 1044.5,458.336 1044.5,458.75 C1044.5,459.164 1044.836,459.5 1045.25,459.5 L1047,459.5 L1047,461.25 C1047,461.664 1047.336,462 1047.75,462 C1048.164,462 1048.5,461.664 1048.5,461.25 L1048.5,459.5 L1050.25,459.5 C1050.664,459.5 1051,459.164 1051,458.75"></path>' +
                '</g>',
            snooze:
                '<g transform="translate(-1077, -481)">' +
                '<path d="M1099.90924,488.566999 C1098.88024,486.670999 1097.33224,485.122999 1095.43324,484.090999 C1095.06724,483.893999 1094.61324,484.028999 1094.41624,484.391999 C1094.21924,484.755999 1094.35324,485.210999 1094.71724,485.408999 C1096.36024,486.301999 1097.70024,487.641999 1098.59124,489.282999 C1098.72624,489.532999 1098.98424,489.674999 1099.25124,489.674999 C1099.37124,489.674999 1099.49424,489.645999 1099.60724,489.583999 C1099.97124,489.385999 1100.10624,488.930999 1099.90924,488.566999 M1090.00024,485.999999 C1085.58924,485.999999 1082.00024,489.588999 1082.00024,493.999999 C1082.00024,498.410999 1085.58924,501.999999 1090.00024,501.999999 C1094.41124,501.999999 1098.00024,498.410999 1098.00024,493.999999 C1098.00024,489.588999 1094.41124,485.999999 1090.00024,485.999999 M1096.50024,493.999999 C1096.50024,497.583999 1093.58424,500.499999 1090.00024,500.499999 C1086.41624,500.499999 1083.50024,497.583999 1083.50024,493.999999 C1083.50024,490.415999 1086.41624,487.499999 1090.00024,487.499999 C1093.58424,487.499999 1096.50024,490.415999 1096.50024,493.999999 M1092.64724,495.897999 L1089.16224,495.897999 L1093.17724,491.881999 C1093.39224,491.667999 1093.45624,491.344999 1093.34124,491.064999 C1093.22424,490.784999 1092.95124,490.601999 1092.64724,490.601999 L1087.35224,490.601999 C1086.93824,490.601999 1086.60224,490.937999 1086.60224,491.351999 C1086.60224,491.765999 1086.93824,492.101999 1087.35224,492.101999 L1090.83724,492.101999 L1086.82224,496.117999 C1086.60724,496.332999 1086.54324,496.654999 1086.65924,496.934999 C1086.77524,497.215999 1087.04924,497.397999 1087.35224,497.397999 L1092.64724,497.397999 C1093.06124,497.397999 1093.39724,497.061999 1093.39724,496.647999 C1093.39724,496.233999 1093.06124,495.897999 1092.64724,495.897999 M1085.58424,484.391999 C1085.38624,484.026999 1084.93124,483.893999 1084.56724,484.090999 C1082.67024,485.120999 1081.12224,486.667999 1080.09124,488.566999 C1079.89324,488.930999 1080.02824,489.385999 1080.39224,489.583999 C1080.50624,489.645999 1080.62824,489.674999 1080.74924,489.674999 C1081.01524,489.674999 1081.27324,489.532999 1081.40924,489.282999 C1082.30224,487.639999 1083.64124,486.299999 1085.28224,485.408999 C1085.64624,485.211999 1085.78124,484.755999 1085.58424,484.391999"></path>' +
                '</g>',
            dragHandle:
                '<g transform="translate(4, 4)">' +
                '<path d="M2,1 C2,0.448 1.552,0 1,0 C0.448,0 0,0.448 0,1 C0,1.552 0.448,2 1,2 C1.552,2 2,1.552 2,1 Z M2,5.6667 C2,5.1147 1.552,4.6667 1,4.6667 C0.448,4.6667 0,5.1147 0,5.6667 C0,6.2187 0.448,6.6667 1,6.6667 C1.552,6.6667 2,6.2187 2,5.6667 Z M2,15 C2,14.448 1.552,14 1,14 C0.448,14 0,14.448 0,15 C0,15.552 0.448,16 1,16 C1.552,16 2,15.552 2,15 Z M2,10.3333 C2,9.7813 1.552,9.3333 1,9.3333 C0.448,9.3333 0,9.7813 0,10.3333 C0,10.8853 0.448,11.3333 1,11.3333 C1.552,11.3333 2,10.8853 2,10.3333 Z M7,1 C7,0.448 6.552,0 6,0 C5.448,0 5,0.448 5,1 C5,1.552 5.448,2 6,2 C6.552,2 7,1.552 7,1 Z M7,5.6667 C7,5.1147 6.552,4.6667 6,4.6667 C5.448,4.6667 5,5.1147 5,5.6667 C5,6.2187 5.448,6.6667 6,6.6667 C6.552,6.6667 7,6.2187 7,5.6667 Z M7,15 C7,14.448 6.552,14 6,14 C5.448,14 5,14.448 5,15 C5,15.552 5.448,16 6,16 C6.552,16 7,15.552 7,15 Z M7,10.3333 C7,9.7813 6.552,9.3333 6,9.3333 C5.448,9.3333 5,9.7813 5,10.3333 C5,10.8853 5.448,11.3333 6,11.3333 C6.552,11.3333 7,10.8853 7,10.3333 Z M12,1 C12,0.448 11.552,0 11,0 C10.448,0 10,0.448 10,1 C10,1.552 10.448,2 11,2 C11.552,2 12,1.552 12,1 Z M12,5.6667 C12,5.1147 11.552,4.6667 11,4.6667 C10.448,4.6667 10,5.1147 10,5.6667 C10,6.2187 10.448,6.6667 11,6.6667 C11.552,6.6667 12,6.2187 12,5.6667 Z M12,15 C12,14.448 11.552,14 11,14 C10.448,14 10,14.448 10,15 C10,15.552 10.448,16 11,16 C11.552,16 12,15.552 12,15 Z M12,10.3333 C12,9.7813 11.552,9.3333 11,9.3333 C10.448,9.3333 10,9.7813 10,10.3333 C10,10.8853 10.448,11.3333 11,11.3333 C11.552,11.3333 12,10.8853 12,10.3333 Z"></path>' +
                '</g>',
            visibilityOn:
                '<g transform="translate(-1032.000000, -368)">' +
                '<path d="M1053.86975,379.578 C1053.68675,379.31 1049.32375,373 1042.99975,373 C1036.67575,373 1032.31175,379.31 1032.12975,379.578 C1031.95675,379.833 1031.95675,380.167 1032.12975,380.422 C1032.31175,380.69 1036.67575,387 1042.99975,387 C1049.32375,387 1053.68675,380.69 1053.86975,380.422 C1054.04275,380.167 1054.04275,379.833 1053.86975,379.578 M1042.17275,374.588 C1042.44875,374.559 1042.71575,374.5 1042.99975,374.5 C1043.28375,374.5 1043.55175,374.559 1043.82775,374.588 C1045.63775,374.971 1046.99975,376.579 1046.99975,378.5 C1046.99975,380.705 1045.20575,382.5 1042.99975,382.5 C1040.79375,382.5 1038.99975,380.705 1038.99975,378.5 C1038.99975,376.578 1040.36275,374.971 1042.17275,374.588 M1052.31475,380 C1051.26275,381.355 1047.65675,385.5 1042.99975,385.5 C1038.35475,385.5 1034.73975,381.353 1033.68375,380 C1034.32775,379.171 1035.93275,377.306 1038.14075,375.977 C1037.74475,376.736 1037.49975,377.586 1037.49975,378.5 C1037.49975,381.532 1039.96675,384 1042.99975,384 C1046.03175,384 1048.49975,381.532 1048.49975,378.5 C1048.49975,377.589 1048.25575,376.741 1047.86175,375.984 C1050.06475,377.313 1051.67075,379.174 1052.31475,380"></path>' +
                '</g>',
            visibilityOff:
                '<g transform="translate(-1032, -436)">' +
                '<path d="M1053.8705,447.578 C1053.6875,447.31 1049.3245,441 1043.0005,441 C1036.6765,441 1032.3125,447.31 1032.1305,447.578 C1031.9565,447.833 1031.9565,448.167 1032.1305,448.422 C1032.3125,448.69 1036.6765,455 1043.0005,455 C1049.3245,455 1053.6875,448.69 1053.8705,448.422 C1054.0435,448.167 1054.0435,447.833 1053.8705,447.578 M1042.1735,442.588 C1042.4495,442.559 1042.7165,442.5 1043.0005,442.5 C1043.8325,442.5 1044.6055,442.756 1045.2465,443.193 L1039.6935,448.746 C1039.2565,448.105 1039.0005,447.332 1039.0005,446.5 C1039.0005,444.578 1040.3635,442.971 1042.1735,442.588 M1047.0005,446.5 C1047.0005,448.705 1045.2065,450.5 1043.0005,450.5 C1042.1685,450.5 1041.3955,450.243 1040.7545,449.807 L1046.3075,444.254 C1046.7435,444.895 1047.0005,445.668 1047.0005,446.5 M1052.3155,448 C1051.2635,449.355 1047.6575,453.5 1043.0005,453.5 C1038.3555,453.5 1034.7405,449.353 1033.6845,448 C1034.3285,447.171 1035.9335,445.306 1038.1415,443.977 C1037.7455,444.736 1037.5005,445.586 1037.5005,446.5 C1037.5005,449.532 1039.9675,452 1043.0005,452 C1046.0325,452 1048.5005,449.532 1048.5005,446.5 C1048.5005,445.603 1048.2645,444.768 1047.8815,444.019 C1050.0735,445.343 1051.6745,447.178 1052.3155,448"></path>' +
                '</g>',
            editOrder:
                '<g transform="translate(-1079, -20)">' +
                '<path d="M1100.7645,25.7955 C1101.0665,25.5105 1101.0805,25.0365 1100.7945,24.7345 L1096.5445,20.2345 C1096.5425,20.2325 1096.5395,20.2315 1096.5365,20.2295 C1096.4005,20.0895 1096.2115,19.9995 1096.0005,19.9995 C1095.7885,19.9995 1095.5995,20.0885 1095.4635,20.2295 C1095.4605,20.2315 1095.4575,20.2325 1095.4555,20.2345 L1091.2055,24.7345 C1090.9205,25.0365 1090.9345,25.5105 1091.2355,25.7955 C1091.5365,26.0795 1092.0105,26.0665 1092.2945,25.7655 L1095.2505,22.6365 L1095.2505,37.3635 L1092.2945,34.2355 C1092.0105,33.9345 1091.5365,33.9185 1091.2355,34.2055 C1090.9345,34.4895 1090.9205,34.9635 1091.2055,35.2645 L1095.4555,39.7645 C1095.4575,39.7665 1095.4605,39.7675 1095.4625,39.7695 C1095.5215,39.8305 1095.5935,39.8765 1095.6695,39.9155 C1095.6825,39.9215 1095.6925,39.9335 1095.7055,39.9395 C1095.7955,39.9775 1095.8955,39.9995 1096.0005,39.9995 C1096.1045,39.9995 1096.2035,39.9775 1096.2945,39.9395 C1096.3075,39.9335 1096.3175,39.9215 1096.3295,39.9155 C1096.4065,39.8765 1096.4785,39.8305 1096.5375,39.7695 C1096.5395,39.7675 1096.5425,39.7665 1096.5445,39.7645 L1100.7945,35.2645 C1101.0805,34.9635 1101.0665,34.4895 1100.7645,34.2055 C1100.4635,33.9185 1099.9895,33.9345 1099.7055,34.2355 L1096.7505,37.3635 L1096.7505,22.6365 L1099.7055,25.7655 C1099.8525,25.9215 1100.0505,25.9995 1100.2505,25.9995 C1100.4345,25.9995 1100.6195,25.9325 1100.7645,25.7955 M1089.0005,34.7495 C1089.0005,34.3355 1088.6645,33.9995 1088.2505,33.9995 L1079.7505,33.9995 C1079.3355,33.9995 1079.0005,34.3355 1079.0005,34.7495 C1079.0005,35.1635 1079.3355,35.4995 1079.7505,35.4995 L1088.2505,35.4995 C1088.6645,35.4995 1089.0005,35.1635 1089.0005,34.7495 M1089.0005,29.9995 C1089.0005,29.5855 1088.6645,29.2495 1088.2505,29.2495 L1079.7505,29.2495 C1079.3355,29.2495 1079.0005,29.5855 1079.0005,29.9995 C1079.0005,30.4135 1079.3355,30.7495 1079.7505,30.7495 L1088.2505,30.7495 C1088.6645,30.7495 1089.0005,30.4135 1089.0005,29.9995 M1089.0005,25.2495 C1089.0005,24.8355 1088.6645,24.4995 1088.2505,24.4995 L1079.7505,24.4995 C1079.3355,24.4995 1079.0005,24.8355 1079.0005,25.2495 C1079.0005,25.6645 1079.3355,25.9995 1079.7505,25.9995 L1088.2505,25.9995 C1088.6645,25.9995 1089.0005,25.6645 1089.0005,25.2495"></path>' +
                '</g>',
            email:
                '<g transform="translate(-1030, -568)">' +
                '<path d="M1054,587.251 L1054,572.75 C1054,572.336 1053.664,572 1053.25,572 L1030.75,572 C1030.336,572 1030,572.336 1030,572.75 L1030,587.239 C1030,587.653 1030.335,587.989 1030.75,587.989 L1053.25,588 C1053.449,588 1053.639,587.921 1053.78,587.781 C1053.921,587.64 1054,587.45 1054,587.251 L1054,587.251 Z M1031.5,574.377 L1037.584,579.351 L1031.5,585.43 L1031.5,574.377 Z M1038.75,580.305 L1041.525,582.573 C1041.663,582.686 1041.832,582.743 1042,582.743 C1042.168,582.743 1042.337,582.686 1042.475,582.573 L1045.249,580.305 L1051.45,586.501 L1032.56,586.49 L1038.75,580.305 Z M1032.796,573.499 L1051.205,573.499 L1042,581.025 L1032.796,573.499 Z M1052.5,574.377 L1052.5,585.43 L1046.416,579.351 L1052.5,574.377 Z" id="Email"></path>' +
                '</g>',
            spiritualConversation:
                '<g transform="translate(-634, -20)">' +
                '<path d="M658,39.2499 C658,38.8359 657.664,38.4999 657.25,38.4999 L650.542,38.4999 C651.448,37.8389 652.19,36.9839 652.74,35.9999 L653.25,35.9999 C655.317,35.9999 657,34.3179 657,32.2499 C657,30.1819 655.317,28.4999 653.25,28.4999 L653,28.4999 L652.75,28.4999 L639,28.4999 C638.586,28.4999 638.25,28.8359 638.25,29.2499 L638.25,32.2499 C638.25,34.8219 639.523,37.0899 641.458,38.4999 L634.75,38.4999 C634.336,38.4999 634,38.8359 634,39.2499 C634,39.6639 634.336,39.9999 634.75,39.9999 L657.25,39.9999 C657.664,39.9999 658,39.6639 658,39.2499 M653.386,34.4719 C653.6,33.7639 653.75,33.0279 653.75,32.2499 L653.75,30.1009 C654.743,30.3349 655.5,31.1869 655.5,32.2499 C655.5,33.4419 654.56,34.3979 653.386,34.4719 M646,38.4999 C642.554,38.4999 639.75,35.6959 639.75,32.2499 L639.75,29.9999 L652.25,29.9999 L652.25,32.2499 C652.25,35.6959 649.446,38.4999 646,38.4999 M649.75,26.7499 L649.75,23.2499 C649.75,22.8359 649.414,22.4999 649,22.4999 C648.586,22.4999 648.25,22.8359 648.25,23.2499 L648.25,26.7499 C648.25,27.1639 648.586,27.4999 649,27.4999 C649.414,27.4999 649.75,27.1639 649.75,26.7499 M646.75,26.7499 L646.75,20.7499 C646.75,20.3359 646.414,19.9999 646,19.9999 C645.586,19.9999 645.25,20.3359 645.25,20.7499 L645.25,26.7499 C645.25,27.1639 645.586,27.4999 646,27.4999 C646.414,27.4999 646.75,27.1639 646.75,26.7499 M643.75,26.7499 L643.75,23.2499 C643.75,22.8359 643.414,22.4999 643,22.4999 C642.586,22.4999 642.25,22.8359 642.25,23.2499 L642.25,26.7499 C642.25,27.1639 642.586,27.4999 643,27.4999 C643.414,27.4999 643.75,27.1639 643.75,26.7499"></path>' +
                '</g>',
            note:
                '<g transform="translate(-984, -212)">' +
                '<path d="M1004.00008,228.499969 L1004.00008,212.749903 C1004.00008,212.335901 1003.66408,211.9999 1003.25008,211.9999 L986.250009,211.9999 C985.836008,211.9999 985.500006,212.335901 985.500006,212.749903 L985.500006,217.249922 L984.750003,217.249922 C984.336001,217.249922 984,217.585923 984,217.999925 C984,218.413927 984.336001,218.749928 984.750003,218.749928 L985.500006,218.749928 L985.500006,223.249947 L984.750003,223.249947 C984.336001,223.249947 984,223.585948 984,223.99995 C984,224.413952 984.336001,224.749953 984.750003,224.749953 L985.500006,224.749953 L985.500006,228.999971 L984.750003,228.999971 C984.336001,228.999971 984,229.335972 984,229.749974 C984,230.163976 984.336001,230.499977 984.750003,230.499977 L985.500006,230.499977 L985.500006,235.249997 C985.500006,235.663999 985.836008,236 986.250009,236 L996.500052,236 C996.602053,236 996.699053,235.98 996.788053,235.943 C996.876054,235.906 996.959054,235.851999 997.030054,235.779999 L1003.78008,229.029971 C1003.85208,228.958971 1003.90608,228.87597 1003.94208,228.78797 C1003.97908,228.69897 1004.00008,228.601969 1004.00008,228.499969 L1004.00008,228.499969 Z M997.250055,229.249972 L1001.43907,229.249972 L997.250055,233.439989 L997.250055,229.249972 Z M1002.50008,227.749966 L996.500052,227.749966 C996.08605,227.749966 995.750049,228.085967 995.750049,228.499969 L995.750049,234.499994 L987.000013,234.499994 L987.000013,230.499977 L987.750016,230.499977 C988.164017,230.499977 988.500019,230.163976 988.500019,229.749974 C988.500019,229.335972 988.164017,228.999971 987.750016,228.999971 L987.000013,228.999971 L987.000013,224.749953 L987.750016,224.749953 C988.164017,224.749953 988.500019,224.413952 988.500019,223.99995 C988.500019,223.585948 988.164017,223.249947 987.750016,223.249947 L987.000013,223.249947 L987.000013,218.749928 L987.750016,218.749928 C988.164017,218.749928 988.500019,218.413927 988.500019,217.999925 C988.500019,217.585923 988.164017,217.249922 987.750016,217.249922 L987.000013,217.249922 L987.000013,213.499906 L1002.50008,213.499906 L1002.50008,227.749966 Z M991.25003,221.749941 L999.250064,221.749941 C999.664065,221.749941 1000.00007,221.413939 1000.00007,220.999937 C1000.00007,220.585936 999.664065,220.249934 999.250064,220.249934 L991.25003,220.249934 C990.836028,220.249934 990.500027,220.585936 990.500027,220.999937 C990.500027,221.413939 990.836028,221.749941 991.25003,221.749941 L991.25003,221.749941 Z M1000.00007,217.999925 C1000.00007,217.585923 999.664065,217.249922 999.250064,217.249922 L991.25003,217.249922 C990.836028,217.249922 990.500027,217.585923 990.500027,217.999925 C990.500027,218.413927 990.836028,218.749928 991.25003,218.749928 L999.250064,218.749928 C999.664065,218.749928 1000.00007,218.413927 1000.00007,217.999925 L1000.00007,217.999925 Z M990.500027,223.99995 C990.500027,224.413952 990.836028,224.749953 991.25003,224.749953 L995.000046,224.749953 C995.414048,224.749953 995.750049,224.413952 995.750049,223.99995 C995.750049,223.585948 995.414048,223.249947 995.000046,223.249947 L991.25003,223.249947 C990.836028,223.249947 990.500027,223.585948 990.500027,223.99995 L990.500027,223.99995 Z"></path>' +
                '</g>',
            archive:
                '<g transform="translate(-1031, -212)">' +
                '<path d="M1053,228.25 L1053,224.75 C1053,224.739 1052.994,224.73 1052.994,224.72 C1052.992,224.665 1052.976,224.615 1052.962,224.562 C1052.951,224.52 1052.945,224.476 1052.927,224.437 C1052.908,224.396 1052.877,224.361 1052.85,224.324 C1052.82,224.281 1052.793,224.238 1052.754,224.202 C1052.746,224.195 1052.743,224.184 1052.734,224.177 L1049.484,221.427 C1049.349,221.313 1049.178,221.25 1049,221.25 L1043.038,221.25 L1046.792,217.331 C1047.078,217.032 1047.068,216.558 1046.769,216.271 C1046.469,215.984 1045.994,215.994 1045.708,216.294 L1042.75,219.382 L1042.75,212.75 C1042.75,212.336 1042.414,212 1042,212 C1041.586,212 1041.25,212.336 1041.25,212.75 L1041.25,219.382 L1038.292,216.294 C1038.005,215.994 1037.529,215.984 1037.231,216.271 C1036.932,216.558 1036.922,217.032 1037.209,217.331 L1040.962,221.25 L1035,221.25 C1034.823,221.25 1034.651,221.313 1034.516,221.427 L1031.266,224.177 C1031.257,224.184 1031.254,224.195 1031.246,224.202 C1031.207,224.238 1031.18,224.281 1031.149,224.324 C1031.123,224.362 1031.092,224.396 1031.074,224.437 C1031.055,224.476 1031.049,224.52 1031.038,224.562 C1031.024,224.615 1031.008,224.666 1031.006,224.72 C1031.006,224.731 1031,224.739 1031,224.75 L1031,228.25 C1031,228.664 1031.336,229 1031.75,229 L1032.5,229 L1032.5,235.25 C1032.5,235.664 1032.836,236 1033.25,236 L1050.75,236 C1051.164,236 1051.5,235.664 1051.5,235.25 L1051.5,229 L1052.25,229 C1052.664,229 1053,228.664 1053,228.25 L1053,228.25 Z M1034,229 L1037,229 C1037,230.654 1038.346,232 1040,232 L1044,232 C1045.654,232 1047,230.654 1047,229 L1050,229 L1050,234.5 L1034,234.5 L1034,229 Z M1044,230.5 L1040,230.5 C1039.173,230.5 1038.5,229.827 1038.5,229 L1045.5,229 C1045.5,229.827 1044.827,230.5 1044,230.5 L1044,230.5 Z M1050.203,224 L1033.797,224 L1035.275,222.75 L1048.726,222.75 L1050.203,224 Z M1051.5,227.5 L1050.75,227.5 L1033.25,227.5 L1032.5,227.5 L1032.5,225.5 L1051.5,225.5 L1051.5,227.5 Z"></path>' +
                '</g>',
        });

        /* eslint-enable max-len */

        I18n.fallbacks = true;
        $qProvider.errorOnUnhandledRejections(false);
    });
