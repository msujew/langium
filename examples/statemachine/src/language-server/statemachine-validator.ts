import { ValidationAcceptor, ValidationCheck, ValidationRegistry } from 'langium';
import { State, StatemachineAstType } from './generated/ast';
import { StatemachineServices } from './statemachine-module';

type StatemachineChecks = { [type in StatemachineAstType]?: ValidationCheck | ValidationCheck[] }

export class StatemachineValidationRegistry extends ValidationRegistry {
    constructor(services: StatemachineServices) {
        super(services);
        const validator = services.validation.StatemachineValidator;
        const checks: StatemachineChecks = {
            State: validator.checkStateNameStartsWithLowerCase
        };
        this.register(checks, validator);
    }
}

export class StatemachineValidator {

    checkStateNameStartsWithLowerCase(state: State, accept: ValidationAcceptor): void {
        if (state.name) {
            const firstChar = state.name.substring(0, 1);
            if (firstChar.toLowerCase() !== firstChar) {
                accept('warning', 'State name should start with a lower case letter.', { node: state, property: 'name' });
            }
        }
	}

}
