import SwiftUI

struct ListaComprasView: View {
    
    @State private var articulos: [Articulo] = []
    @State private var articulosSeleccionados: Set<Articulo> = []
    @State private var categorias: [String] = []
    @State private var tiendas: [String] = []
    @State private var categoriaSeleccionada: String?
    @State private var tiendaSeleccionada: String?
    
    @State private var isAgregarArticuloPresented: Bool = false
    
    // FetchArticulos es el método que recupera los artículos de Core Data
    func fetchArticulos() {
        // Usamos el "try?" para manejar el error de manera segura.
        if let fetchedArticulos = try? CoreDataManagerCompras.shared.cargarArticulos() {
            articulos = fetchedArticulos
        }
    }
    
    // Llamada a eliminar artículos seleccionados
    func eliminarArticulosSeleccionados() {
        do {
            try CoreDataManagerCompras.shared.eliminarArticulosSeleccionados(articulosSeleccionados: Array(articulosSeleccionados))
            fetchArticulos()  // Recargamos los artículos después de la eliminación
        } catch {
            print("Error al eliminar artículos: \(error)")
        }
    }
    
    // Llamada a marcar artículos seleccionados como comprados
    func marcarArticulosComprados() {
        do {
            try CoreDataManagerCompras.shared.marcarArticulosComprados(articulosSeleccionados: Array(articulosSeleccionados))
            fetchArticulos()  // Recargamos los artículos después de la actualización
        } catch {
            print("Error al marcar artículos como comprados: \(error)")
        }
    }
    
    // Llamada a filtrar artículos por categoría y tienda
    func filtrarArticulos() {
        do {
            articulos = try CoreDataManagerCompras.shared.filtrarArticulos(categoria: categoriaSeleccionada, tienda: tiendaSeleccionada) ?? []
        } catch {
            print("Error al filtrar artículos: \(error)")
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Filtro
                HStack {
                    Picker("Categoría", selection: $categoriaSeleccionada) {
                        Text("Todas").tag(String?.none)
                        ForEach(categorias, id: \.self) { categoria in
                            Text(categoria).tag(categoria as String?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: categoriaSeleccionada) { _ in
                        filtrarArticulos()
                    }
                    
                    Picker("Tienda", selection: $tiendaSeleccionada) {
                        Text("Todas").tag(String?.none)
                        ForEach(tiendas, id: \.self) { tienda in
                            Text(tienda).tag(tienda as String?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: tiendaSeleccionada) { _ in
                        filtrarArticulos()
                    }
                }
                .padding()
                
                // Lista de artículos
                List(articulos, id: \.self, selection: $articulosSeleccionados) { articulo in
                    NavigationLink(destination: DetalleArticuloView(articulo: articulo)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(articulo.nombre ?? "")
                                    .font(.headline)
                                Text("Cantidad: \(articulo.cantidad)")
                                    .font(.subheadline)
                                Text("Prioridad: \(articulo.prioridad ?? "")")
                                    .font(.subheadline)
                                
                            }
                            Spacer()
                            if articulo.comprado {
                                Text("Comprado")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(articulosSeleccionados.contains(articulo) ? Color.blue.opacity(0.1) : Color.clear)
                        .cornerRadius(8)
                    }
                }
                
                // Barra de botones para eliminar y marcar como comprados
                HStack {
                    Button("Marcar como Comprado") {
                        marcarArticulosComprados()
                    }
                    .foregroundColor(.green)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.green))
                    
                    Button("Eliminar") {
                        eliminarArticulosSeleccionados()
                    }
                    .foregroundColor(.red)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.red))
                }
                
                Spacer()
            }
            .navigationBarItems(trailing: Button(action: {
                isAgregarArticuloPresented.toggle()
            }) {
                Image(systemName: "plus")
                    .font(.title)
            })
            .onAppear {
                fetchArticulos()
                
                // Fetch Categorías
                ApiManager.shared.fetchCategorias { categorias, error in
                    if let categorias = categorias {
                        self.categorias = categorias
                    } else if let error = error {
                        print("Error al cargar categorías: \(error.localizedDescription)")
                    }
                }

                
                // Fetch Tiendas
                ApiManager.shared.fetchTiendas { tiendas, error in
                    if let tiendas = tiendas {
                        self.tiendas = tiendas
                    } else if let error = error {
                        print("Error al cargar tiendas: \(error.localizedDescription)")
                    }
                }

            }
            .sheet(isPresented: $isAgregarArticuloPresented) {
                AgregarArticuloView(isPresented: $isAgregarArticuloPresented)
            }
        }
        .navigationTitle("Lista de Compras")
    }
}
//
