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
        let members = declaration.as(StructDeclSyntax.self)?.memberBlock.members ??
            declaration.as(ClassDeclSyntax.self)?.memberBlock.members ?? []

        let variableDecls = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }

        let list = variableDecls.map {
            (
                $0.attributes?.first?.as(AttributeSyntax.self)?
                    .attributeName.description == "AnandaKey"
                    ? $0.attributes?.first?.as(AttributeSyntax.self)?
                        .argument?.as(TupleExprElementListSyntax.self)?.first?
                        .as(TupleExprElementSyntax.self)?.expression
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

        let initializer = try InitializerDeclSyntax(
            .init(stringLiteral: "init(json: AnandaJSON)")
        ) {
            for (key, name, type) in list {
                ExprSyntax("self.\(name) = \(raw: type.ananda(key: key))")
            }
        }

        return [DeclSyntax(initializer)]
    }
}

extension TypeSyntax {
    func ananda(key: String) -> String {
        if let simpleType = self.as(SimpleTypeIdentifierSyntax.self) {
            switch simpleType.name.text {
            case "Bool":
                return "json.\(key).bool()"
            case "Int":
                return "json.\(key).int()"
            case "UInt":
                return "json.\(key).uInt()"
            case "Double":
                return "json.\(key).double()"
            case "String":
                return "json.\(key).string()"
            case "URL":
                return "json.\(key).url()"
            case "Date":
                return "json.\(key).date()"
            default:
                return ".init(json: json.\(key))"
            }
        }

        if let optionalType = self.as(OptionalTypeSyntax.self) {
            if let simpleType = optionalType.wrappedType.as(SimpleTypeIdentifierSyntax.self) {
                switch simpleType.name.text {
                case "Bool":
                    return "json.\(key).bool"
                case "Int":
                    return "json.\(key).int"
                case "UInt":
                    return "json.\(key).uInt"
                case "Double":
                    return "json.\(key).double"
                case "String":
                    return "json.\(key).string"
                case "URL":
                    return "json.\(key).url"
                case "Date":
                    return "json.\(key).date"
                default:
                    return "json.\(key).isEmpty ? nil : .init(json: json.\(key))"
                }
            }

            if let arrayType = optionalType.wrappedType.as(ArrayTypeSyntax.self) {
                if let simpleType = arrayType.elementType.as(SimpleTypeIdentifierSyntax.self) {
                    switch simpleType.name.text {
                    case "Bool":
                        return "json.\(key).isEmpty ? nil : json.\(key).array().map { $0.bool() }"
                    case "Int":
                        return "json.\(key).isEmpty ? nil : json.\(key).array().map { $0.int() }"
                    case "UInt":
                        return "json.\(key).isEmpty ? nil : json.\(key).array().map { $0.uInt() }"
                    case "Double":
                        return "json.\(key).isEmpty ? nil : json.\(key).array().map { $0.double() }"
                    case "String":
                        return "json.\(key).isEmpty ? nil : json.\(key).array().map { $0.string() }"
                    case "URL":
                        return "json.\(key).isEmpty ? nil : json.\(key).array().map { $0.url() }"
                    case "Date":
                        return "json.\(key).isEmpty ? nil : json.\(key).array().map { $0.date() }"
                    default:
                        return "json.\(key).isEmpty ? nil : json.\(key).array().map { .init(json: $0) }"
                    }
                }
            }
        }

        if let arrayType = self.as(ArrayTypeSyntax.self) {
            if let simpleType = arrayType.elementType.as(SimpleTypeIdentifierSyntax.self) {
                switch simpleType.name.text {
                case "Bool":
                    return "json.\(key).array().map { $0.bool() }"
                case "Int":
                    return "json.\(key).array().map { $0.int() }"
                case "UInt":
                    return "json.\(key).array().map { $0.uInt() }"
                case "Double":
                    return "json.\(key).array().map { $0.double() }"
                case "String":
                    return "json.\(key).array().map { $0.string() }"
                case "URL":
                    return "json.\(key).array().map { $0.url() }"
                case "Date":
                    return "json.\(key).array().map { $0.date() }"
                default:
                    return "json.\(key).array().map { .init(json: $0) }"
                }
            }
        }

        return ""
    }
}
