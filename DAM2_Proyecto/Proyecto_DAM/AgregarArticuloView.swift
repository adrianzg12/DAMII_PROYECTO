import SwiftUI

struct AgregarArticuloView: View {
    
    @Binding var isPresented: Bool
    @State private var nombre: String = ""
    @State private var cantidad: Int = 1
    @State private var prioridad: String = "Alta"
    @State private var notas: String = ""
    
    @State private var categorias: [String] = []
    @State private var tiendas: [String] = []
    
    @State private var categoriaSeleccionada: String = ""
    @State private var tiendaSeleccionada: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalles del artículo")) {
                    TextField("Nombre", text: $nombre)
                    Stepper("Cantidad: \(cantidad)", value: $cantidad, in: 1...100)
                    TextField("Notas", text: $notas)
                    Picker("Prioridad", selection: $prioridad) {
                        Text("Alta").tag("Alta")
                        Text("Baja").tag("Baja")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Categoría y Tienda")) {
                    Picker("Categoría", selection: $categoriaSeleccionada) {
                        ForEach(categorias, id: \.self) { categoria in
                            Text(categoria).tag(categoria)
                        }
                    }
                    
                    Picker("Tienda", selection: $tiendaSeleccionada) {
                        ForEach(tiendas, id: \.self) { tienda in
                            Text(tienda).tag(tienda)
                        }
                    }
                }
            }
            .navigationBarItems(leading: Button("Cancelar") {
                isPresented = false
            }, trailing: Button("Guardar") {
                // Intentar guardar el artículo con manejo de errores
                do {
                    try CoreDataManagerCompras.shared.guardarArticulo(
                        nombre: nombre,
                        cantidad: Int32(cantidad),
                        prioridad: prioridad,
                        notas: notas,
                        categoria: categoriaSeleccionada,
                        tienda: tiendaSeleccionada
                    )
                    isPresented = false  // Cerrar la vista al guardar
                } catch {
                    print("Error al guardar el artículo: \(error)") // Manejo de errores
                    // Aquí puedes mostrar una alerta al usuario si lo deseas.
                }
            })
            .onAppear {
                ApiManager.shared.fetchCategorias { categorias, error in
                    if let categorias = categorias {
                        self.categorias = categorias
                    } else if let error = error {
                        print("Error al cargar categorías: \(error.localizedDescription)")
                    }
                }


                ApiManager.shared.fetchTiendas { tiendas, error in
                    if let tiendas = tiendas {
                        self.tiendas = tiendas
                    } else if let error = error {
                        print("Error al cargar tiendas: \(error.localizedDescription)")
                    }
                }
                
            }
        }
    }
}
