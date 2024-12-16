import SwiftUI

struct DetalleArticuloView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var articulo: Articulo  // Artículo que se pasa a la vista

    var body: some View {
        Form {
            // Sección de detalles del artículo
            Section(header: Text("Detalles del Artículo")) {
                Text("Nombre: \(articulo.nombre ?? "No disponible")")
                Text("Cantidad: \(articulo.cantidad)")
                Text("Prioridad: \(articulo.prioridad ?? "No especificada")")
                Text("Notas adicionales: \(articulo.notas ?? "No hay notas")")
            }

            // Sección de categoría y tienda
            Section(header: Text("Categoría y Tienda")) {
                Text("Categoría: \(articulo.categoria ?? "No especificada")")
                Text("Tienda: \(articulo.tienda ?? "No especificada")")
            }
        }
        .navigationTitle("Detalles del Artículo")
        .navigationBarItems(trailing: Button("Cerrar") {
            presentationMode.wrappedValue.dismiss()
        })
    }
}
