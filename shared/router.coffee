Router.map ->

  @route "entrySignIn",
    path: "/sign-in"
    # tgtg
    onBeforeAction: ->
      Session.set('entryError', undefined)
      Session.set('buttonText', 'in')

  @route "entrySignUp",
    path: "/sign-up"
    onBeforeAction: ->
      Session.set('entryError', undefined)
      Session.set('buttonText', 'up')

  @route "entryForgotPassword",
    path: "/forgot-password"
    onBeforeAction: ->
      Session.set('entryError', undefined)

  @route 'entrySignOut',
    path: '/sign-out'
    template: 'home'
    onBeforeAction: ->
      Session.set('entryError', undefined)
      if AccountsEntry.settings.homeRoute
        Meteor.logout () ->
          # Router.go AccountsEntry.settings.homeRoute
      @stop()
      Router.go("home")
    # onRun: ->
    #   Router.go("home")
    # onAfterAction: ->
    #   console.log "tg"
    #   checkHeaderColor this
    #   bindTestimonialClicker()
    # onStop: ->
    #   headerNormalize()
    # #   unbindTestimonialClicker()
    # waitOn: ->
    #   Meteor.subscribe "RecentlySold"
    #   Meteor.subscribe "Testimonials"
    #   Meteor.subscribe "DeviceTypes"

  @route 'entryResetPassword',
    path: 'reset-password/:resetToken'
    onBeforeAction: ->
      Session.set('entryError', undefined)
      Session.set('resetToken', @params.resetToken)
