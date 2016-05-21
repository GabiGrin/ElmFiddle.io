var expect = require('chai').expect;
var Q = require('q');
var coverage = require('../coverage');

module.exports = function (browser) {
    // Test for false, because null should default to true
    if (
        browser.desiredCapabilities.webStorageEnabled === false ||
        browser.desiredCapabilities.rafEnabled === false
    ) return;
    
    describe("The Window example", function () {
        beforeEach(function () {
            return browser.url('http://localhost:8080/build/window.html');
        });

        afterEach(function () {
            return coverage.collect(browser);
        });

        // Don't test alerts etc. under Safari, because Selenium can't
        // manage alerts with Safari.
        var describeAlert = (
            browser.desiredCapabilities.browserName == 'safari' ||
            browser.desiredCapabilities.browserName == 'opera'
        ) ? describe.skip : describe;
                       
        var truthy = function () {
            return Q.when(true);
        };

        var falsy = function () {
            return Q.when(false); 
        };

        describeAlert("alert", function () {
            it("should open", function () {
                return browser
                    .click("#alert-button")
                    
                    .waitUntil(function () {
                        return this.alertText().then(truthy, falsy);
                    }, 30000, 500)
                    
                    .alertText().then(function (text) {
                        expect(text).to.equal("Hello world!");
                    })
                    
                    .alertAccept();
            });
        });
            
        describeAlert("confirm", function () {
            it("should recognize acceptance", function () {
                return browser
                    .click("#confirm-button")

                    .waitUntil(function () {
                        return this.alertText().then(truthy, falsy);
                    }, 30000, 500)
                    
                    .alertText().then(function (text) {
                        expect(text).to.equal("Do you agree?");
                    })
                    
                    .alertAccept()
                    
                    .waitUntil(function () {
                        return this.getText("#message").then(function (text) {
                            return text.indexOf("Pressed OK") >= 0;
                        });
                    }, 30000, 500);
            });

            it("should recognize rejection", function () {
                return browser
                    .click("#confirm-button")
                    
                    .waitUntil(function () {
                        return this.alertText().then(truthy, falsy);
                    }, 30000, 500)
                    
                    .alertText().then(function (text) {
                        expect(text).to.equal("Do you agree?");
                    })
                    
                    .alertDismiss()
                    
                    .waitUntil(function () {
                        return this.getText("#message").then(function (text) {
                            return text.indexOf("Pressed cancel") >= 0;
                        });
                    }, 30000, 500);
            });
        });

        describeAlert("prompt", function () {
            it("should recognize dismissal", function () {
                return browser
                    .click("#prompt-button")

                    .waitUntil(function () {
                        return this.alertText().then(truthy, falsy);
                    }, 30000, 500)
                    
                    .alertText().then(function (text) {
                        expect(text).to.equal("What is your favourite colour?");
                    })
                    
                    .alertDismiss()
                    
                    .waitUntil(function () {
                        return this.getText("#message").then(function (text) {
                            return text.indexOf("User canceled.") >= 0;
                        });
                    }, 30000, 500);
            });
            
            it("should return default when accepted", function () {
                return browser
                    .click("#prompt-button")

                    .waitUntil(function () {
                        return this.alertText().then(truthy, falsy);
                    }, 30000, 500)
                    
                    .alertText().then(function (text) {
                        expect(text).to.equal("What is your favourite colour?");
                    })
                    
                    .alertAccept()
                    
                    .waitUntil(function () {
                        return this.getText("#message").then(function (text) {
                            return text.indexOf("Got response: Blue") >= 0;
                        });
                    }, 30000, 500);
            });

            // These don't work on iPhone because the alertText() isn't cleared
            var run = browser.desiredCapabilities.browserName == 'iphone' ? it.skip : it;

            run("should interpret empty string as dismissal", function () {
                return browser
                    .click("#prompt-button")
                    
                    .waitUntil(function () {
                        return this.alertText().then(truthy, falsy);
                    }, 30000, 500)
                    
                    .alertText("")
                    .alertAccept()
                    
                    .waitUntil(function () {
                        return this.getText("#message").then(function (text) {
                            return text.indexOf("User canceled.") >= 0;
                        });
                    }, 30000, 500);
            });
            
            run("should return entered text if entered", function () {
                return browser
                    .click("#prompt-button")
                    
                    .waitUntil(function () {
                        return this.alertText().then(truthy, falsy);
                    }, 30000, 500)
                    
                    .alertText("Red")
                    .alertAccept()

                    .waitUntil(function () {
                        return this.getText("#message").then(function (text) {
                            return text.indexOf("Got response: Red") >= 0;
                        });
                    }, 30000, 500);
            });
        });
    });
};
