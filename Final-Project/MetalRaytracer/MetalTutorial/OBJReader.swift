//
//  OBJReader.swift
//  MetalRaytracer
//
//  Created by Justin A on 12/2/24.
//

import Foundation

// Gets the vertices and indicies from the obj file
func getObjData(objFile: String) -> (verts: [Float], indices: [Int]) {
    var verts: [Float] = []
    var indices: [Int] = []
    
    if let filePath = Bundle.main.path(forResource: "teapot", ofType: "obj") {
        do {
            let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
            let lines = fileContents.split(separator: "\n")
            
            for line in lines {
                let components = line.split(separator: " ")
                if components.isEmpty { continue }
                
                switch components[0] {
                case "v": // Vertex
                    let x = Float(components[1]) ?? 0.0
                    let y = Float(components[2]) ?? 0.0
                    let z = Float(components[3]) ?? 0.0
                    verts.append(contentsOf: [x, y, z])
                case "f": // Face
                    let v1 = Int(components[1]) ?? 0;
                    let v2 = Int(components[2]) ?? 0;
                    let v3 = Int(components[3]) ?? 0;
                    indices.append(contentsOf: [v1, v2, v3])
                default:
                    break
                }
            }
        } catch {
            print("Error reading file: \(error.localizedDescription)")
        }
    } else {
        print("File not found in bundle.")
    }

    return (verts, indices)
}
