/******************************************************************************
 * Copyright 2021 TypeFox GmbH
 * This program and the accompanying materials are made available under the
 * terms of the MIT License, which is available in the project root.
 ******************************************************************************/

import { Module, inject } from '../dependency-injection';
import { LangiumGrammarValidationRegistry, LangiumGrammarValidator } from './langium-grammar-validator';
import { PartialLangiumServices, LangiumServices } from '../services';
import { DefaultModuleContext, createDefaultModule } from '../default-module';
import { LangiumGrammarGeneratedModule } from './generated/module';

export type LangiumGrammarAddedServices = {
    validation: {
        LangiumGrammarValidator: LangiumGrammarValidator
    }
}

export type LangiumGrammarServices = LangiumServices & LangiumGrammarAddedServices

export const LangiumGrammarModule: Module<LangiumGrammarServices, PartialLangiumServices & LangiumGrammarAddedServices> = {
    validation: {
        ValidationRegistry: (injector) => new LangiumGrammarValidationRegistry(injector),
        LangiumGrammarValidator: () => new LangiumGrammarValidator()
    }
};

export function createLangiumGrammarServices(context?: DefaultModuleContext): LangiumGrammarServices {
    return inject(
        createDefaultModule(context),
        LangiumGrammarGeneratedModule,
        LangiumGrammarModule
    );
}
