package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"sync"

	"golang.org/x/net/websocket"

	"revolut-clone-server/database"
	"revolut-clone-server/middleware"
)

// Client represents a WebSocket client
type Client struct {
	UserID string
	Conn   *websocket.Conn
	Send   chan []byte
}

// Hub manages WebSocket connections
type Hub struct {
	clients    map[*Client]bool
	broadcast  chan Message
	register   chan *Client
	unregister chan *Client
	mu         sync.RWMutex
}

// Message represents a WebSocket message
type Message struct {
	UserID  string      `json:"userId"`
	Type    string      `json:"type"`
	Payload interface{} `json:"payload"`
}

var hub = &Hub{
	clients:    make(map[*Client]bool),
	broadcast:  make(chan Message, 256),
	register:   make(chan *Client),
	unregister: make(chan *Client),
}

// init starts the WebSocket hub
func init() {
	go hub.run()
}

func (h *Hub) run() {
	for {
		select {
		case client := <-h.register:
			h.mu.Lock()
			h.clients[client] = true
			h.mu.Unlock()
			log.Printf("Client connected: %s (Total: %d)", client.UserID, len(h.clients))

		case client := <-h.unregister:
			h.mu.Lock()
			if _, ok := h.clients[client]; ok {
				delete(h.clients, client)
				close(client.Send)
			}
			h.mu.Unlock()
			log.Printf("Client disconnected: %s (Total: %d)", client.UserID, len(h.clients))

		case message := <-h.broadcast:
			h.mu.RLock()
			for client := range h.clients {
				// Only send to clients with matching user ID
				if client.UserID == message.UserID {
					msgBytes, err := json.Marshal(message)
					if err != nil {
						continue
					}
					select {
					case client.Send <- msgBytes:
					default:
						close(client.Send)
						delete(h.clients, client)
					}
				}
			}
			h.mu.RUnlock()
		}
	}
}

// HandleWebSocket handles WebSocket connections
func HandleWebSocket(w http.ResponseWriter, r *http.Request) {
	userID := r.Context().Value(middleware.UserIDKey).(string)

	server := websocket.Server{
		Handler: websocket.Handler(func(ws *websocket.Conn) {
			client := &Client{
				UserID: userID,
				Conn:   ws,
				Send:   make(chan []byte, 256),
			}

			hub.register <- client
			defer func() {
				hub.unregister <- client
				ws.Close()
			}()

			// Start write pump in a goroutine
			go client.writePump()

			// Read pump (blocking)
			client.readPump()
		}),
	}

	server.ServeHTTP(w, r)
}

// readPump reads messages from the WebSocket connection
func (c *Client) readPump() {
	for {
		var msg []byte
		err := websocket.Message.Receive(c.Conn, &msg)
		if err != nil {
			break
		}
		// We don't process incoming messages for now, just keep connection alive
	}
}

// writePump writes messages to the WebSocket connection
func (c *Client) writePump() {
	for message := range c.Send {
		if err := websocket.Message.Send(c.Conn, string(message)); err != nil {
			log.Printf("WebSocket write error: %v", err)
			return
		}
	}
}

// BroadcastTransactionUpdate broadcasts a transaction update to all connected clients of a user
func BroadcastTransactionUpdate(userID string, transaction database.Transaction) {
	message := Message{
		UserID:  userID,
		Type:    "transaction_created",
		Payload: transaction,
	}
	hub.broadcast <- message
}

// BroadcastTransactionDeletion broadcasts a transaction deletion to all connected clients of a user
func BroadcastTransactionDeletion(userID string, transactionID string) {
	message := Message{
		UserID:  userID,
		Type:    "transaction_deleted",
		Payload: map[string]string{"id": transactionID},
	}
	hub.broadcast <- message
}
