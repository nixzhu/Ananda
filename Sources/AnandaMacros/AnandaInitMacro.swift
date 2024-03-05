import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct AnandaInitMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let accessModifierHead: String = {
            let names = declaration.as(StructDeclSyntax.self)?.modifiers.map {
                $0.name.trimmed.text
            } ?? declaration.as(ClassDeclSyntax.self)?.modifiers.map {
                $0.name.trimmed.text
            } ?? []

            if names.contains("public") {
                return "public "
            }

            if names.contains("internal") {
                return "internal "
            }

            if names.contains("fileprivate") {
                return "fileprivate "
            }

            if names.contains("private") {
                return "private "
            }

            return ""
        }()

        let members = declaration.as(StructDeclSyntax.self)?.memberBlock.members ??
            declaration.as(ClassDeclSyntax.self)?.memberBlock.members ?? []

        let variableDecls = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }

        #if canImport(SwiftSyntax510)
        let list = variableDecls
            .filter {
                $0.bindings.first?.accessorBlock == nil &&
                    $0.attributes.first?.as(AttributeSyntax.self)?
                    .attributeName.description != "AnandaIgnored"
            }
            .map {
                (
                    $0.attributes.first?.as(AttributeSyntax.self)?
                        .attributeName.description == "AnandaKey"
                        ? $0.attributes.first?.as(AttributeSyntax.self)?
                            .arguments?.as(LabeledExprListSyntax.self)?.first?.expression
                            .as(StringLiteralExprSyntax.self)?.segments.first?.description
                        : nil,
                    $0.bindings.first?.pattern,
                    $0.bindings.first?.typeAnnotation?.type
                )
            }
            .compactMap { key, name, type -> (String, PatternSyntax, TypeSyntax)? in
                guard let name else {
                    return nil
                }

                guard let type else {
                    return nil
                }

                return (key ?? name.description, name, type)
            }
        #else
        let list = variableDecls
            .filter {
                $0.bindings.first?.accessorBlock == nil &&
                    $0.attributes.first?.as(AttributeSyntax.self)?
                    .attributeName.description != "AnandaIgnored"
            }
            .map {
                (
                    $0.attributes.first?.as(AttributeSyntax.self)?
                        .attributeName.description == "AnandaKey"
                        ? $0.attributes.first?.as(AttributeSyntax.self)?
                            .arguments?.as(LabeledExprListSyntax.self)?.first?
                            .as(LabeledExprSyntax.self)?.expression
                            .as(StringLiteralExprSyntax.self)?.segments.first?.description
                        : nil,
                    $0.bindings.first?.pattern,
                    $0.bindings.first?.typeAnnotation?.type
                )
            }
            .compactMap { key, name, type -> (String, PatternSyntax, TypeSyntax)? in
                guard let name else {
                    return nil
                }

                guard let type else {
                    return nil
                }

                return (key ?? name.description, name, type)
            }
        #endif

        let initializer = try InitializerDeclSyntax(
            .init(stringLiteral: "\(accessModifierHead)init(json: AnandaJSON)")
        ) {
            for (key, name, type) in list {
                ExprSyntax("self.\(name) = \(raw: type.ananda(key: key))")
            }
        }

        return [DeclSyntax(initializer)]
    }
}

extension TypeSyntax {
    fileprivate func ananda(key: String) -> String {
        let json = "json[\"\(key)\"]"

        if let simpleType = self.as(IdentifierTypeSyntax.self) {
            switch simpleType.name.text {
            case "Bool":
                return "\(json).bool()"
            case "Int":
                return "\(json).int()"
            case "Double":
                return "\(json).double()"
            case "String":
                return "\(json).string()"
            case "URL":
                return "\(json).url()"
            case "Date":
                return "\(json).date()"
            default:
                return ".init(json: \(json))"
            }
        }

        if let dictionaryType = self.as(DictionaryTypeSyntax.self) {
            if let simpleType = dictionaryType.value.as(IdentifierTypeSyntax.self) {
                switch simpleType.name.text {
                case "Bool":
                    return "\(json).dictionary().mapValues { $0.bool() }"
                case "Int":
                    return "\(json).dictionary().mapValues { $0.int() }"
                case "Double":
                    return "\(json).dictionary().mapValues { $0.double() }"
                case "String":
                    return "\(json).dictionary().mapValues { $0.string() }"
                case "URL":
                    return "\(json).dictionary().mapValues { $0.url() }"
                case "Date":
                    return "\(json).dictionary().mapValues { $0.date() }"
                default:
                    return "\(json).dictionary().mapValues { .init(json: $0) }"
                }
            }

            if let arrayType = dictionaryType.value.as(ArrayTypeSyntax.self) {
                if let simpleType = arrayType.element.as(IdentifierTypeSyntax.self) {
                    switch simpleType.name.text {
                    case "Bool":
                        return "\(json).dictionary().mapValues { $0.array().map { $0.bool() } }"
                    case "Int":
                        return "\(json).dictionary().mapValues { $0.array().map { $0.int() } }"
                    case "Double":
                        return "\(json).dictionary().mapValues { $0.array().map { $0.double() } }"
                    case "String":
                        return "\(json).dictionary().mapValues { $0.array().map { $0.string() } }"
                    case "URL":
                        return "\(json).dictionary().mapValues { $0.array().map { $0.url() } }"
                    case "Date":
                        return "\(json).dictionary().mapValues { $0.array().map { $0.date() } }"
                    default:
                        return "\(json).dictionary().mapValues { $0.array().map { .init(json: $0) } }"
                    }
                }
            }
        }

        if let arrayType = self.as(ArrayTypeSyntax.self) {
            if let simpleType = arrayType.element.as(IdentifierTypeSyntax.self) {
                switch simpleType.name.text {
                case "Bool":
                    return "\(json).array().map { $0.bool() }"
                case "Int":
                    return "\(json).array().map { $0.int() }"
                case "Double":
                    return "\(json).array().map { $0.double() }"
                case "String":
                    return "\(json).array().map { $0.string() }"
                case "URL":
                    return "\(json).array().map { $0.url() }"
                case "Date":
                    return "\(json).array().map { $0.date() }"
                default:
                    return "\(json).array().map { .init(json: $0) }"
                }
            }

            if let dictionaryType = arrayType.element.as(DictionaryTypeSyntax.self) {
                if let simpleType = dictionaryType.value.as(IdentifierTypeSyntax.self) {
                    switch simpleType.name.text {
                    case "Bool":
                        return "\(json).array().map { $0.dictionary().mapValues { $0.bool() } }"
                    case "Int":
                        return "\(json).array().map { $0.dictionary().mapValues { $0.int() } }"
                    case "Double":
                        return "\(json).array().map { $0.dictionary().mapValues { $0.double() } }"
                    case "String":
                        return "\(json).array().map { $0.dictionary().mapValues { $0.string() } }"
                    case "URL":
                        return "\(json).array().map { $0.dictionary().mapValues { $0.url() } }"
                    case "Date":
                        return "\(json).array().map { $0.dictionary().mapValues { $0.date() } }"
                    default:
                        return "\(json).array().map { $0.dictionary().mapValues { .init(json: $0) } }"
                    }
                }

                if let arrayType = dictionaryType.value.as(ArrayTypeSyntax.self) {
                    if let simpleType = arrayType.element.as(IdentifierTypeSyntax.self) {
                        switch simpleType.name.text {
                        case "Bool":
                            return "\(json).array().map { $0.dictionary().mapValues { $0.array().map { $0.bool() } } }"
                        case "Int":
                            return "\(json).array().map { $0.dictionary().mapValues { $0.array().map { $0.int() } } }"
                        case "Double":
                            return "\(json).array().map { $0.dictionary().mapValues { $0.array().map { $0.double() } } }"
                        case "String":
                            return "\(json).array().map { $0.dictionary().mapValues { $0.array().map { $0.string() } } }"
                        case "URL":
                            return "\(json).array().map { $0.dictionary().mapValues { $0.array().map { $0.url() } } }"
                        case "Date":
                            return "\(json).array().map { $0.dictionary().mapValues { $0.array().map { $0.date() } } }"
                        default:
                            return "\(json).array().map { $0.dictionary().mapValues { $0.array().map { .init(json: $0) } } }"
                        }
                    }
                }
            }
        }

        if let optionalType = self.as(OptionalTypeSyntax.self) {
            if let simpleType = optionalType.wrappedType.as(IdentifierTypeSyntax.self) {
                switch simpleType.name.text {
                case "Bool":
                    return "\(json).bool"
                case "Int":
                    return "\(json).int"
                case "Double":
                    return "\(json).double"
                case "String":
                    return "\(json).string"
                case "URL":
                    return "\(json).url"
                case "Date":
                    return "\(json).date"
                default:
                    return "\(json).emptyAsNil.map { .init(json: $0) }"
                }
            }

            if let dictionaryType = optionalType.wrappedType.as(DictionaryTypeSyntax.self) {
                if let simpleType = dictionaryType.value.as(IdentifierTypeSyntax.self) {
                    switch simpleType.name.text {
                    case "Bool":
                        return "\(json).dictionary?.mapValues { $0.bool() }"
                    case "Int":
                        return "\(json).dictionary?.mapValues { $0.int() }"
                    case "Double":
                        return "\(json).dictionary?.mapValues { $0.double() }"
                    case "String":
                        return "\(json).dictionary?.mapValues { $0.string() }"
                    case "URL":
                        return "\(json).dictionary?.mapValues { $0.url() }"
                    case "Date":
                        return "\(json).dictionary?.mapValues { $0.date() }"
                    default:
                        return "\(json).dictionary?.mapValues { .init(json: $0) }"
                    }
                }

                if let arrayType = dictionaryType.value.as(ArrayTypeSyntax.self) {
                    if let simpleType = arrayType.element.as(IdentifierTypeSyntax.self) {
                        switch simpleType.name.text {
                        case "Bool":
                            return "\(json).dictionary?.mapValues { $0.array().map { $0.bool() } }"
                        case "Int":
                            return "\(json).dictionary?.mapValues { $0.array().map { $0.int() } }"
                        case "Double":
                            return "\(json).dictionary?.mapValues { $0.array().map { $0.double() } }"
                        case "String":
                            return "\(json).dictionary?.mapValues { $0.array().map { $0.string() } }"
                        case "URL":
                            return "\(json).dictionary?.mapValues { $0.array().map { $0.url() } }"
                        case "Date":
                            return "\(json).dictionary?.mapValues { $0.array().map { $0.date() } }"
                        default:
                            return "\(json).dictionary?.mapValues { $0.array().map { .init(json: $0) } }"
                        }
                    }
                }
            }

            if let arrayType = optionalType.wrappedType.as(ArrayTypeSyntax.self) {
                if let simpleType = arrayType.element.as(IdentifierTypeSyntax.self) {
                    switch simpleType.name.text {
                    case "Bool":
                        return "\(json).array?.map { $0.bool() }"
                    case "Int":
                        return "\(json).array?.map { $0.int() }"
                    case "Double":
                        return "\(json).array?.map { $0.double() }"
                    case "String":
                        return "\(json).array?.map { $0.string() }"
                    case "URL":
                        return "\(json).array?.map { $0.url() }"
                    case "Date":
                        return "\(json).array?.map { $0.date() }"
                    default:
                        return "\(json).array?.map { .init(json: $0) }"
                    }
                }

                if let dictionaryType = arrayType.element.as(DictionaryTypeSyntax.self) {
                    if let simpleType = dictionaryType.value.as(IdentifierTypeSyntax.self) {
                        switch simpleType.name.text {
                        case "Bool":
                            return "\(json).array?.map { $0.dictionary().mapValues { $0.bool() } }"
                        case "Int":
                            return "\(json).array?.map { $0.dictionary().mapValues { $0.int() } }"
                        case "Double":
                            return "\(json).array?.map { $0.dictionary().mapValues { $0.double() } }"
                        case "String":
                            return "\(json).array?.map { $0.dictionary().mapValues { $0.string() } }"
                        case "URL":
                            return "\(json).array?.map { $0.dictionary().mapValues { $0.url() } }"
                        case "Date":
                            return "\(json).array?.map { $0.dictionary().mapValues { $0.date() } }"
                        default:
                            return "\(json).array?.map { $0.dictionary().mapValues { .init(json: $0) } }"
                        }
                    }

                    if let arrayType = dictionaryType.value.as(ArrayTypeSyntax.self) {
                        if let simpleType = arrayType.element.as(IdentifierTypeSyntax.self) {
                            switch simpleType.name.text {
                            case "Bool":
                                return "\(json).array?.map { $0.dictionary().mapValues { $0.array().map { $0.bool() } } }"
                            case "Int":
                                return "\(json).array?.map { $0.dictionary().mapValues { $0.array().map { $0.int() } } }"
                            case "Double":
                                return "\(json).array?.map { $0.dictionary().mapValues { $0.array().map { $0.double() } } }"
                            case "String":
                                return "\(json).array?.map { $0.dictionary().mapValues { $0.array().map { $0.string() } } }"
                            case "URL":
                                return "\(json).array?.map { $0.dictionary().mapValues { $0.array().map { $0.url() } } }"
                            case "Date":
                                return "\(json).array?.map { $0.dictionary().mapValues { $0.array().map { $0.date() } } }"
                            default:
                                return "\(json).array?.map { $0.dictionary().mapValues { $0.array().map { .init(json: $0) } } }"
                            }
                        }
                    }
                }
            }
        }

        return ""
    }
}
