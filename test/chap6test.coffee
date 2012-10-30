(require 'chai').should()
chap6 = require '../src/chap6'

describe 'Account', ->

  describe '#getBalance()', ->

    it 'should return 0 when no entries', ->
      account = new chap6.Account()
      account.entries.length.should.equal 0
      account.getBalance().should.equal 0

    it 'should return the sum of entry amount', ->
      account = new chap6.Account()
      entry1 = new chap6.Entry 100.00, account
      entry2 = new chap6.Entry -25.00, account
      each.post() for each in [entry1, entry2]
      account.getBalance().should.equal 75.00

describe 'Transaction', ->

  it 'should post to an Account', ->
    account = new chap6.Account()
    trx = new chap6.Transaction()
    trx.add 100.00, account
    trx.add -25.00, account
    trx.add -75.00, account
    trx.post()
    account.getBalance().should.equal 0.00

  it 'should allow a nicety for 2-legged transaction', ->
    account = new chap6.Account()
    trx = new chap6.Transaction()
    trx.add 100.00, account, account
    trx.post()
    account.getBalance().should.equal 0.00

  it 'should prevent posting if sum is not 0', ->
    account = new chap6.Account()
    trx = new chap6.Transaction()
    trx.add 100.00, account
    trx.add -25.00, account
    try
      trx.post()
      throw new Error "should not get here"
    catch err

  it 'should prevent double posting', ->
    account = new chap6.Account()
    trx = new chap6.Transaction()
    trx.add 100.00, account
    trx.add -100.00, account
    trx.post()
    try
      trx.post()
      throw new Error "should not get here"
    catch err

describe 'SummaryAccount', ->

  it 'should return the sum of all balances', ->
    subAccount1 = new chap6.Account()
    subAccount2 = new chap6.Account()
    summaryAccount = new chap6.SummaryAccount()
    summaryAccount.add subAccount1
    summaryAccount.add subAccount2
    trx = new chap6.Transaction()
    trx.add 100.00, subAccount1, subAccount2
    trx.post()

    subAccount1.getBalance().should.equal 100.00
    subAccount2.getBalance().should.equal -100.00
    summaryAccount.getBalance().should.equal 0.00

describe 'PostingRule', ->

  it 'should post an entry to a memo account when posting to detail account', ->
    detailAccount = new chap6.Account()
    memoAccount = new chap6.Account()
    chap6.PostingRule.create detailAccount, (entry) ->
      (new chap6.Entry 0.45 * entry.amount, memoAccount).post()

    (new chap6.Entry 100.00, detailAccount).post()

    memoAccount.getBalance().should.equal 45.00

