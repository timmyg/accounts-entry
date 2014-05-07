# Template.entrySignUp.rendered = ->
#   dropZoneNewUserInit()

Template.entrySignUp.helpers
  showEmail: ->
    fields = Accounts.ui._options.passwordSignupFields

    _.contains([
      'USERNAME_AND_EMAIL',
      'USERNAME_AND_OPTIONAL_EMAIL',
      'EMAIL_ONLY'], fields)

  showUsername: ->
    fields = Accounts.ui._options.passwordSignupFields

    _.contains([
      'USERNAME_AND_EMAIL',
      'USERNAME_AND_OPTIONAL_EMAIL',
      'USERNAME_ONLY'], fields)

  showSignupCode: ->
    AccountsEntry.settings.showSignupCode

  logo: ->
    AccountsEntry.settings.logo

  privacyUrl: ->
    AccountsEntry.settings.privacyUrl

  termsUrl: ->
    AccountsEntry.settings.termsUrl

  both: ->
    AccountsEntry.settings.privacyUrl &&
    AccountsEntry.settings.termsUrl

  neither: ->
    !AccountsEntry.settings.privacyUrl &&
    !AccountsEntry.settings.termsUrl

Template.entrySignUp.events
  'click .remove': ->
    Session.set "passwordSignupImage", undefined
  'submit #signUp': (event, t) ->
    console.log "signing up"
    event.preventDefault()
    username =
      if t.find('input[name="username"]')
        t.find('input[name="username"]').value
      else
        undefined

    signupCode =
      if t.find('input[name="signupCode"]')
        t.find('input[name="signupCode"]').value
      else
        undefined

    email = t.find('input[type="email"]').value
    password = t.find('input[type="password"]').value
    firstname = t.find('input#firstname').value
    # lastname = t.find('input#lastname').value
    businessname = t.find('input#businessname').value
    address = t.find('input#address').value
    city = t.find('input#city').value
    state = t.find('input#state').value
    zip = t.find('input#zipcode').value

    fields = Accounts.ui._options.passwordSignupFields

    # trimInput = (val)->
    #   val.replace /^\s*|\s*$/g, ""

    passwordErrors = do (password)->
      errMsg = []
      msg = false
      if password.length < 7
        errMsg.push "7 character minimum password."
      if password.search(/[a-z]/i) < 0
        errMsg.push "Password requires 1 letter."
      if password.search(/[0-9]/) < 0
        errMsg.push "Password must have at least one digit."

      if errMsg.length > 0
        msg = ""
        errMsg.forEach (e) ->
          msg = msg.concat "#{e}\r\n"

        Session.set 'entryError', msg
        return true

      return false

    if passwordErrors then return

    # email = email
    # firstname = firstname
    # lastname = lastname
    # zip = trimInput zip
    profile = new Object()
    profile.email = email
    profile.first_name = businessname
    profile.contact_first_name = firstname
    profile.business_name = businessname
    profile.business = true
    # profile.lastname = lastname
    # profile.zip = zip
    # profile.name = "#{firstname} #{lastname}"
    profile.address = address
    profile.city = city
    profile.state = state
    profile.zip = zip
    # profile.img = image

    image = Session.get("passwordSignupImage")
    images = new Object()
    images.pic = image
    images.pic_small = image
    images.pic_big = image
    images.pic_square = image
    profile.images = images

    # user.positives = 0
    # user.negatives = 0
    # user.credits = 0

    emailRequired = _.contains([
      'USERNAME_AND_EMAIL',
      'EMAIL_ONLY'], fields)

    usernameRequired = _.contains([
      'USERNAME_AND_EMAIL',
      'USERNAME_ONLY'], fields)

    if usernameRequired && email.length is 0
      Session.set('entryError', 'Username is required')
      return

    if emailRequired && email.length is 0
      Session.set('entryError', 'Email is required')
      return

    if AccountsEntry.settings.showSignupCode && signupCode.length is 0
      Session.set('entryError', 'Signup code is required')
      return

    #TODO fix to fit with this design
    if firstname.length is 0
      Session.set('entryError', 'First Name is required')
      return
    # if lastname.length is 0
    #   Session.set('entryError', 'Last Name is required')
      return
    if zip.length is 0
      Session.set('entryError', 'Zip is required')
      return
    if zip.length < 5
      Session.set('entryError', 'Zip must be at least 5 digits')
      return

    Meteor.call('entryValidateSignupCode', signupCode, (err, valid) ->
      # if err
      if valid
        console.log "valid"
        newUserData =
          email: email
          password: password
          profile: profile
          business: true
        if username
          data.username = username
        console.log "newUserData"
        console.log newUserData
        Accounts.createUser newUserData, (err, data) ->
          if err
            # Session.set('entryError', err.reason)
            Alerts.add err.details, "warning" 
            return
          #login on client
          if  _.contains([
            'USERNAME_AND_EMAIL',
            'EMAIL_ONLY'], AccountsEntry.settings.passwordSignupFields)
            Meteor.loginWithPassword(email, password)
            Router.go("/")
          else
            Meteor.loginWithPassword(username, password)
            Router.go("/")

          # Router.go AccountsEntry.settings.dashboardRoute
      else
        Session.set('entryError', i18n("error.signupCodeIncorrect"))
        return
    )