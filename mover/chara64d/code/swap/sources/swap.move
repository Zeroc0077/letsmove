module swap::swap {
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::tx_context::sender;
    use su_coin::chara64d_faucet_coin::{CHARA64D_FAUCET_COIN};
    use su_coin::chara64d_coin::{CHARA64D_COIN};

    public struct Bank has key {
        id: UID,
        USD: Balance<CHARA64D_COIN>,
        RMB: Balance<CHARA64D_FAUCET_COIN>,
        rate: u64, 
    }

    public struct AdminCap has key {
        id: UID,
    }

    public fun get_rate(bank: &Bank): u64 {
        bank.rate
    }

    public entry fun set_rate(_: &AdminCap, bank: &mut Bank, rate: u64, _: &mut TxContext) {
        bank.rate= rate;
    }

    fun init(ctx: &mut TxContext) {
        let bank = Bank {
            id: object::new(ctx),
            USD: balance::zero<CHARA64D_COIN>(),
            RMB: balance::zero<CHARA64D_FAUCET_COIN>(),
            rate: 7,
        };
        transfer::share_object(bank);

        let admin_cap = AdminCap { id: object::new(ctx) };
        transfer::transfer(admin_cap, sender(ctx));
    }

    public entry fun deposit_RMB(bank:&mut Bank,rmb:Coin<CHARA64D_FAUCET_COIN>,_:&mut TxContext){
        balance::join(&mut bank.RMB,coin::into_balance(rmb));
    }

    public entry fun deposit_USD(bank:&mut Bank,usd:Coin<CHARA64D_COIN>,_:&mut TxContext){
        balance::join(&mut bank.USD,coin::into_balance(usd));
    }

    public entry fun swap_usd2rmb(bank: &mut Bank, usd: Coin<CHARA64D_COIN>, ctx: &mut TxContext) {
        let usd_amount = coin::value(&usd);
        let rmb_amount = usd_amount * bank.rate;

        balance::join(&mut bank.USD, coin::into_balance(usd));

        let rmb_balance = balance::split(&mut bank.RMB, rmb_amount);
        let rmb = coin::from_balance(rmb_balance, ctx);

        transfer::public_transfer(rmb, sender(ctx));
    }

    public entry fun swap_rmb2usd(bank: &mut Bank, rmb: Coin<CHARA64D_FAUCET_COIN>, ctx: &mut TxContext) {

        let rmb_amount = coin::value(&rmb);
        let usd_amount = rmb_amount / bank.rate;

        balance::join(&mut bank.RMB, coin::into_balance(rmb));

        let usd_balance = balance::split(&mut bank.USD, usd_amount);
        let usd = coin::from_balance(usd_balance, ctx);

        transfer::public_transfer(usd, sender(ctx));
    }

}