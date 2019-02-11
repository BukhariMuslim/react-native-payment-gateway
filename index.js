import {NativeModules} from 'react-native';

const {MidtransModule} = NativeModules;

export default {
    checkOut: function (optionConect: ?object,
                        transRequest: ?object,
                        itemDetails: ?object,
                        creditCardOptions: ?object,
                        mapUserDetail: ?object,
                        optionColorTheme: ?object,
                        optionFont: ?object,
                        paymentMethod: ?object,
                        resultCheckOut) {
        MidtransModule.checkOut(
            optionConect,
            transRequest,
            itemDetails,
            creditCardOptions,
            mapUserDetail,
            optionColorTheme,
            optionFont,
            paymentMethod,
            resultCheckOut);
    },
};
