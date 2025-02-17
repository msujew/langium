/******************************************************************************
 * Copyright 2021 TypeFox GmbH
 * This program and the accompanying materials are made available under the
 * terms of the MIT License, which is available in the project root.
 ******************************************************************************/

import { Connection, TextDocuments } from 'vscode-languageserver/node';
import { Module } from './dependency-injection';
import { LangiumDocumentConfiguration } from './documents/document';
import { DefaultDocumentBuilder } from './documents/document-builder';
import { DefaultCompletionProvider } from './lsp/completion/completion-provider';
import { RuleInterpreter } from './lsp/completion/rule-interpreter';
import { DefaultDocumentHighlighter } from './lsp/document-highlighter';
import { DefaultDocumentSymbolProvider } from './lsp/document-symbol-provider';
import { DefaultGoToResolverProvider } from './lsp/goto';
import { DefaultReferenceFinder } from './lsp/reference-finder';
import { DefaultValueConverter } from './parser/value-converter';
import { DefaultLinker } from './references/linker';
import { DefaultNameProvider } from './references/naming';
import { DefaultReferences } from './references/references';
import { DefaultScopeComputation, DefaultScopeProvider } from './references/scope';
import { DefaultJsonSerializer } from './serializer/json-serializer';
import { LangiumDefaultServices, LangiumServices } from './services';
import { DefaultDocumentValidator } from './validation/document-validator';
import { ValidationRegistry } from './validation/validation-registry';

export type DefaultModuleContext = {
    connection?: Connection
}

export function createDefaultModule(context: DefaultModuleContext = {}): Module<LangiumServices, LangiumDefaultServices> {
    return {
        parser: {
            ValueConverter: () => new DefaultValueConverter()
        },
        documents: {
            DocumentBuilder: (injector) => new DefaultDocumentBuilder(injector),
            TextDocuments: () => new TextDocuments(LangiumDocumentConfiguration)
        },
        lsp: {
            completion: {
                CompletionProvider: (injector) => new DefaultCompletionProvider(injector),
                RuleInterpreter: () => new RuleInterpreter()
            },
            Connection: () => context.connection,
            DocumentSymbolProvider: (injector) => new DefaultDocumentSymbolProvider(injector),
            ReferenceFinder:  (injector) => new DefaultReferenceFinder(injector),
            GoToResolver: (injector) => new DefaultGoToResolverProvider(injector),
            DocumentHighlighter: (injector) => new DefaultDocumentHighlighter(injector)
        },
        references: {
            Linker: (injector) => new DefaultLinker(injector),
            NameProvider: () => new DefaultNameProvider(),
            ScopeProvider: (injector) => new DefaultScopeProvider(injector),
            ScopeComputation: (injector) => new DefaultScopeComputation(injector),
            References: (injector) => new DefaultReferences(injector)
        },
        serializer: {
            JsonSerializer: (injector) => new DefaultJsonSerializer(injector)
        },
        validation: {
            DocumentValidator: (injector) => new DefaultDocumentValidator(injector),
            ValidationRegistry: (injector) => new ValidationRegistry(injector)
        }
    };
}
