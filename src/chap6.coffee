class Account
  constructor: ->
    @entries = []
    @postingRules = []

  getEntries: -> @entries

  getBalance: ->
    @entries.reduce ((acc, each) -> acc + each.amount), 0

  post: (entry) ->
    @entries.push entry
    each.call @, entry for each in @postingRules

  onPost: (callback) ->
    @postingRules.push callback


class SummaryAccount extends Account
  constructor: ->
    @components = []

  add: (account) ->
    @components.push account

  getEntries: ->
    entries = []
    for eachComponent in @components
      entries.push each for each in eachComponent.getEntries()
    entries
  
  getBalance: ->
    @entries = @getEntries()
    super()
        

class Entry
  constructor: (@amount, @account, @whenBooked = new Date()) ->
  
  post: ->
    @account.post @


class Transaction
  constructor: ->
    @entries = []
    @wasPosted = no

  add: (amount, fromAccount, toAccount) ->
    @entries.push new Entry amount, fromAccount
    if toAccount
      @entries.push new Entry -1 * amount, toAccount

  post: ->
    throw new Error "Transaction was already posted or entries don't balance." unless @canPost()
    each.post() for each in @entries
    @wasPosted = yes

  canPost: ->
    not @wasPosted and @sumIsZero()

  sumIsZero: ->
    0 is @entries.reduce ((acc, each) -> acc + each.amount), 0


class PostingRule
  @create: (triggerAccount, callback) ->
    triggerAccount.onPost callback


exports.Account = Account
exports.SummaryAccount = SummaryAccount
exports.Entry = Entry
exports.Transaction = Transaction
exports.PostingRule = PostingRule
