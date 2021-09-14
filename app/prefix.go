package app

import (
	sdk "github.com/cosmos/cosmos-sdk/types"
)

const (
	AccountAddressPrefix = "bs"
)

var (
	AccountPubKeyPrefix    = AccountAddressPrefix + "p"
	ValidatorAddressPrefix = AccountAddressPrefix + "v"
	ValidatorPubKeyPrefix  = AccountAddressPrefix + "vp"
	ConsNodeAddressPrefix  = AccountAddressPrefix + "vc"
	ConsNodePubKeyPrefix   = AccountAddressPrefix + "vcp"
)

func SetConfig() {
	config := sdk.GetConfig()
	config.SetBech32PrefixForAccount(AccountAddressPrefix, AccountPubKeyPrefix)
	config.SetBech32PrefixForValidator(ValidatorAddressPrefix, ValidatorPubKeyPrefix)
	config.SetBech32PrefixForConsensusNode(ConsNodeAddressPrefix, ConsNodePubKeyPrefix)
	config.Seal()
}
