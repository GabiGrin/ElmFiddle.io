// Definition of browsers to test remotely

module.exports = function remote (rev) {
    return [{
        browserName: 'safari',
        version: '6.0',
        platform: 'OS X 10.8',
        build: rev,
        name: 'Safari Mountain Lion ' + rev
    },{
        browserName: 'safari',
        version: '7.0',
        platform: 'OS X 10.9',
        build: rev,
        name: 'Safari Mavericks ' + rev
    },{
        browserName: 'safari',
        version: '8.0',
        platform: 'OS X 10.10',
        build: rev,
        name: 'Safari Yosemite ' + rev
    },{
        browserName: 'safari',
        version: '9.0',
        platform: 'OS X 10.11',
        build: rev,
        name: 'Safari El Capitan ' + rev
    },{
        browserName: 'chrome',
        version: '46.0',
        platform: 'Windows 10',
        build: rev,
        name: 'Chrome Windows 10 46.0 ' + rev
    },{
        browserName: 'chrome',
        version: '45.0',
        platform: 'Windows 10',
        build: rev,
        name: 'Chrome Windows 10 45.0 ' + rev
    },{
        browserName: 'chrome',
        version: '44.0',
        platform: 'Windows 10',
        build: rev,
        name: 'Chrome Windows 10 44.0 ' + rev
    },{
        browserName: 'chrome',
        version: '43.0',
        platform: 'Windows 10',
        build: rev,
        name: 'Chrome Windows 10 43.0 ' + rev
    },{
        browserName: 'firefox',
        version: '41.0',
        platform: 'Linux',
        build: rev,
        name: 'Firefox Linux 41.0 ' + rev
    },{
        browserName: 'firefox',
        version: '40.0',
        platform: 'Linux',
        build: rev,
        name: 'Firefox Linux 40.0 ' + rev
    },{
        browserName: 'firefox',
        version: '39.0',
        platform: 'Linux',
        build: rev,
        name: 'Firefox Linux 39.0 ' + rev
    },{
        browserName: 'firefox',
        version: '38.0',
        platform: 'Linux',
        build: rev,
        name: 'Firefox Linux 38.0 ' + rev
    },{
        browserName: 'internet explorer',
        version: '9.0',
        platform: 'Windows 7',
        build: rev,
        name: 'Internet Explorer 9.0 ' + rev,
    },{
        browserName: 'opera',
        version: '12.15',
        platform: 'Linux',
        build: rev,
        name: 'Opera 12.15 ' + rev,
    },{
        browserName: 'internet explorer',
        version: '10.0',
        platform: 'Windows 8',
        build: rev,
        name: 'Internet Explorer 10.0 ' + rev
    },{
        browserName: 'internet explorer',
        version: '11.0',
        platform: 'Windows 10',
        build: rev,
        name: 'Internet Explorer 11.0 ' + rev
    }];
};
